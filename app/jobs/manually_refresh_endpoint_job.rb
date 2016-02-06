require 'mini_magick'

class ManuallyRefreshEndpointJob < ActiveJob::Base
  queue_as :urgent

  def perform(endpoint)
    logger.debug "refreshing endpoint #{endpoint.url} by user #{endpoint.user.email}"

    # grab page screenshot
    driver = Selenium::WebDriver.for :firefox
    driver.get endpoint.url
    driver.save_screenshot('/tmp/page.png')
    driver.quit

    # render background
    image = MiniMagick::Image.open('/tmp/page.png')
    image.combine_options do |b|
      b.colorspace 'Gray'
      b.blur       '0x6'
    end
    image.format 'png'
    image.write  '/tmp/page_background.png'

    # render focus area
    image = MiniMagick::Image.open('/tmp/page.png')
    image.combine_options do |b|
      b.gravity 'Center'
      b.crop    '30x30%+0x0'
      b.bordercolor 'Red'
      b.border       '1x1'
    end
    image.format     'png'
    image.write      '/tmp/page_center.png'

    # join images together
    background = MiniMagick::Image.new('/tmp/page_background.png')
    focus      = MiniMagick::Image.new('/tmp/page_center.png')
    result = background.composite(focus) do |c|
      c.gravity  'Center'
      c.geometry '+0+0'
    end
    result.write '/tmp/page_focus_view.png'

    # save focus view screenshot
    File.open('/tmp/page_focus_view.png') do |f|
      # TODO does this successfully update?
      focus_view = endpoint.build_focus_view

      focus_view.screenshot = f

      unless focus_view.save
        logger.error "could not save focus view/screenshot for endpoint #{endpoint.id}"
      end
    end

    # update refresh time
    endpoint.last_refreshed_at = Time.now
    unless endpoint.save
      logger.error "could not save updated refresh time for endpoint #{endpoint.id}"
    end
  end
end
