require 'mini_magick'
require 'mkmf'
require 'open3'
require 'socket'
require 'tempfile'
require 'timeout'

GrabPageError        = Class.new(Selenium::WebDriver::Error::WebDriverError)
RenderFocusAreaError = Class.new(StandardError)

class RefreshEndpointWorker
  include Sidekiq::Worker

  def perform(submission_hash)

    # deserialize sidekiq argument
    submission = RefreshSubmission.from_h submission_hash

    # guarantee idempotence
    return unless submission.valid?

    # save typing...
    endpoint = submission.endpoint

    logger.debug "refreshing endpoint #{endpoint.url} by user #{endpoint.user.email}"

    # grab page screenshot
    screenshot = grab_page_screenshot(endpoint.url_with_protocol)

    # delete current screenshot
    endpoint.screenshot.destroy

    # save new screenshot to endpoint
    File.open(screenshot) do |f|
      endpoint.screenshot = f
      endpoint.save!
    end

    # render focus area and attach to endpoin                                                       t
    save_focus_area(endpoint, screenshot)
  rescue GrabPageError => e
    logger.info "error while grabbing screenshot: #{e.message}"
    fail endpoint
  rescue RenderFocusAreaError => e
    logger.info "error while rendering focus area: #{e.message}"
    fail endpoint
  else
    # update refresh time
    endpoint.last_refreshed_at = Time.now
    endpoint.save!
  ensure
    cleanup screenshot
  end

  private

  # Fail the refresh.
  def fail(endpoint)
    unless endpoint.nil?
      endpoint.last_refresh_failure_at = Time.now
      endpoint.save!
    end
  end

  def cleanup(filename)
    unless filename.nil?
      logger.debug "Cleaning up #{filename}"
      File.delete filename if File.file? filename
    end
  end

  def bad_endpoint_selenium?(driver)
    'about:blank' == driver.current_url
  end

  def grab_page_screenshot_selenium(url, driver, driver_params={})
    screenshot = new_temporary_image_filename

    driver = Selenium::WebDriver.for driver, driver_params
    driver.get url
    raise GrabPageError, 'Could not fetch URL' if bad_endpoint_selenium? driver
    driver.save_screenshot(screenshot)

    screenshot
  rescue Selenium::WebDriver::Error::WebDriverError => e
    raise GrabPageError, e.message
  rescue Net::ReadTimeout
    raise GrabPageError, 'Timeout while grabbing page'
  ensure
    driver.quit if driver.kind_of? Selenium::WebDriver::Driver
  end

  def grab_page_screenshot_selenium_firefox(url)
    grab_page_screenshot_selenium url, :firefox
  end

  def phantomjs_running?
    Timeout::timeout(1) do
      begin
        TCPSocket.new('127.0.0.1', 8001).close
        true
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
        false
      end
    end
  rescue Timeout::Error
    false
  end

  def grab_page_screenshot_selenium_phantomjs(url)
    grab_page_screenshot_selenium url, :remote, url: 'http://localhost:8001'
  end

  def webkit2png_available?
    `which webkit2png`
    $?.success?
  end

  def grab_page_screenshot_webkit2png(url)
    # generate file names, knowing that webkit2png appends '-full' to the supplied string
    tmp_filename         = new_temporary_image_filename
    screenshot_dir       = File.dirname  tmp_filename
    screenshot_file_base = File.basename tmp_filename, '.png'
    screenshot_file      = "#{screenshot_file_base}-full.png"
    screenshot_path      = File.join(screenshot_dir, screenshot_file)

    # sensible parameters
    timeout = 15
    width   = 1000
    height  = 800

    # build command string
    # TODO escape URL properly
    cmd = "webkit2png --timeout #{timeout} --fullsize --width #{width} --height #{height} --dir #{screenshot_dir} --filename #{screenshot_file_base} '#{url}'"

    # run
    logger.debug "running command: #{cmd}"
    Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
      status = wait_thr.value
      out    = stdout.read
      err    = stderr.read

      unless status.success? and err.empty?
        error = "webkit2png failed with exit status: #{status}, stderr: #{err}, stdout: #{out}"

        logger.error error
        raise GrabPageError, error
      end

      unless File.file? screenshot_path
        error = "webkit2png failed to produce a screenshot file: #{out}"

        logger.error error
        raise GrabPageError, error
      end
    end

    screenshot_path
  end

  def grab_page_screenshot_fake(url)
    screenshot = new_temporary_image_filename

    uri = URI.parse(url)
    raise GrabPageError, 'Non-HTTP URL' unless uri.kind_of?(URI::HTTP) and not uri.host.nil?

    # generate a solid-color image with ImageMagick
    `convert -size 100x100 xc:#990000 #{screenshot}`

    screenshot
  rescue URI::InvalidURIError
    raise GrabPageError, 'Invalid URL'
  end

  def grab_page_screenshot(url)
    # 1) Use fake grab method, if environmental variable is specifier (very fast)
    # 2) Then try webkit2png method, if available (in background, OSX-only)
    # 3) Otherwise use Selenium (better test, annoying)
    if ENV['UX_TEST_GRABBER']
      grab_page_screenshot_fake url
    elsif phantomjs_running?
      grab_page_screenshot_selenium_phantomjs url
    elsif webkit2png_available?
      grab_page_screenshot_webkit2png url
    else
      grab_page_screenshot_selenium_firefox url
    end
  end

  def new_temporary_image_filename
    Dir::Tmpname.make_tmpname([Rails.root.join('tmp/image-').to_s, '.png'], nil)
  end

  def render_above_fold(screenshot)
    above_fold = new_temporary_image_filename

    image = MiniMagick::Image.open(screenshot)

    if image.height > 1000
      image.crop   "#{image.width}x1000+0x0!"
      image.format 'png'
      image.write  above_fold

      above_fold
    else
      screenshot
    end
  end

  def render_blurry_background(above_fold)
    background = new_temporary_image_filename

    image = MiniMagick::Image.open(above_fold)
    image.combine_options do |b|
      b.colorspace 'Gray'
      b.blur       '0x4'
    end
    image.format 'png'
    image.write  background

    background
  end

  def render_focus_centre(above_fold)
    centre = new_temporary_image_filename

    image = MiniMagick::Image.open(above_fold)
    image.combine_options do |b|
      b.crop        '50x50%+0x0'
      b.bordercolor 'Red'
      b.border      '1x1'
    end
    image.format 'png'
    image.write  centre

    centre
  end

  def merge_background_and_centre(background, centre)
    merged = new_temporary_image_filename

    logger.debug "background #{background}"
    logger.debug "centre #{centre}"

    background = MiniMagick::Image.new(background)
    centre     = MiniMagick::Image.new(centre)
    result = background.composite(centre) do |c|
      c.geometry '+0+0'
    end
    result.format 'png'
    result.write  merged

    merged
  end

  # Focus View: focus area rendering
  #
  # 1) Take the page screenshot
  # 2) Consider all that is above the fold
  # 3) The top-left quadrant is the "focus area"
  # 4) Blur the rest, and draw a minimal border
  def save_focus_area(endpoint, screenshot)
    above_fold = render_above_fold(screenshot)
    background = render_blurry_background(above_fold)
    centre     = render_focus_centre(above_fold)
    focus_area = merge_background_and_centre(background, centre)

    # TODO does this successfully update?
    focus_view = endpoint.focus_view || endpoint.build_focus_view

    # delete current focus area
    focus_view.focus_area.destroy

    File.open(focus_area) do |f|
      focus_view.focus_area = f
      focus_view.save!
    end
  rescue MiniMagick::Error, MiniMagick::Invalid => e
    raise RenderFocusAreaError, e.message
  ensure
    cleanup above_fold
    cleanup background
    cleanup centre
    cleanup focus_area
  end
end
