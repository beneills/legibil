require 'mini_magick'
require 'mkmf'
require 'open3'
require 'tempfile'

GrabPageError        = Class.new(Selenium::WebDriver::Error::WebDriverError)
RenderFocusAreaError = Class.new(StandardError)

class ManuallyRefreshEndpointJob < ActiveJob::Base
  queue_as :urgent

  def perform(endpoint)
    logger.debug "refreshing endpoint #{endpoint.url} by user #{endpoint.user.email}"

    # grab page screenshot
    screenshot = grab_page_screenshot(endpoint.url_with_protocol)

    # render focus area and attach to endpoint
    save_focus_area(endpoint, screenshot)
  rescue GrabPageError => e
    logger.error "error while grabbing screenshot: #{e.message}"
  rescue RenderFocusAreaError => e
    logger.error "error while rendering focus area: #{e.message}"
  else
    # update refresh time
    endpoint.last_refreshed_at = Time.now
    endpoint.save!
  end

  private

  def grab_page_screenshot_selenium(url)
    screenshot = new_focus_view_image_filename

    driver = Selenium::WebDriver.for :firefox
    driver.get url
    driver.save_screenshot(screenshot)

    screenshot
  rescue Selenium::WebDriver::Error::WebDriverError => e
    raise GrabPageError, e.message
  ensure
    driver.quit if defined? driver
  end

  def webkit2png_available?
    `which webkit2png`
    $?.success?
  end

  def grab_page_screenshot_webkit2png(url)
    # generate file names, knowing that webkit2png appends '-full' to the supplied string
    tmp_filename         = new_focus_view_image_filename
    screenshot_dir       = File.dirname  tmp_filename
    screenshot_file_base = File.basename tmp_filename, '.png'
    screenshot_file      = "#{screenshot_file_base}-full.png"
    screenshot_path      = File.join(screenshot_dir, screenshot_file)

    # sensible parameters
    timeout = 15
    width   = 1000
    height  = 6000

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
        error = "webkit2png failed with exit status: #{status}, stderr: #{std}, stdout: #{out}"

        logger.error error
        raise GrabPageError, error
      end
    end

    screenshot_path
  end

  def grab_page_screenshot(url)
    # Try webkit2png method first, otherwise use selenium
    if webkit2png_available?
      grab_page_screenshot_webkit2png url
    else
      grab_page_screenshot_selenium url
    end
  end

  def new_focus_view_image_filename
    Dir::Tmpname.make_tmpname([Rails.root.join('tmp/focus-view-').to_s, '.png'], nil)
  end

  def render_blurry_background(screenshot)
    background = new_focus_view_image_filename

    image = MiniMagick::Image.open(screenshot)
    image.combine_options do |b|
      b.colorspace 'Gray'
      b.blur       '0x6'
    end
    image.format 'png'
    image.write  background

    background
  end

  def render_focus_centre(screenshot)
    centre = new_focus_view_image_filename

    image = MiniMagick::Image.open(screenshot)
    image.combine_options do |b|
      b.gravity     'Center'
      b.crop        '30x30%+0x0'
      b.bordercolor 'Red'
      b.border      '1x1'
    end
    image.format 'png'
    image.write  centre

    centre
  end

  def merge_background_and_centre(background, centre)
    merged = new_focus_view_image_filename

    logger.debug "background #{background}"
    logger.debug "centre #{centre}"

    background = MiniMagick::Image.new(background)
    centre     = MiniMagick::Image.new(centre)
    result = background.composite(centre) do |c|
      c.gravity  'Center'
      c.geometry '+0+0'
    end
    result.format 'png'
    result.write  merged

    merged
  end

  def save_focus_area(endpoint, screenshot)
    background = render_blurry_background(screenshot)
    centre     = render_focus_centre(screenshot)
    focus_area = merge_background_and_centre(background, centre)

    File.open(focus_area) do |f|
      # TODO does this successfully update?
      focus_view = endpoint.build_focus_view

      focus_view.screenshot = f
      focus_view.save!
    end
  rescue MiniMagick::Error, MiniMagick::Invalid => e
    raise RenderFocusAreaError, e.message
  end
end
