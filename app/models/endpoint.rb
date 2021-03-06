require 'uri'

class Endpoint < ActiveRecord::Base
  belongs_to :user
  has_one    :focus_view

  has_attached_file :screenshot,
    url: "/images/:hash-:filename",
    default_url: "/images/:style/missing.png",
    hash_secret: Rails.application.secrets.paperclip_hash_secret
  validates_with AttachmentContentTypeValidator, attributes: :screenshot, content_type: /\Aimage\/.*\Z/
  validates_with AttachmentSizeValidator,        attributes: :screenshot, less_than: 1.megabytes

  validates :url,  presence: true
  validates :name, presence: true
  validates :user, presence: true

  validates_length_of :name, :mininum => 1, :maximum => 30

  validate :uniqueness_of_url_and_name_per_user, :on => :create
  validate :good_url

  def uniqueness_of_url_and_name_per_user
    unless self.user.nil?
      if self.user.endpoints.where(url: self.url).exists?
        errors.add(:url, "must be unique")
      end

      if self.user.endpoints.where(name: self.name).exists?
        errors.add(:name, "must be unique")
      end
    end
  end

  def request_ever_requested?
    not self.last_refresh_request_at.nil?
  end

  def ever_successfully_refreshed?
    not self.last_refreshed_at.nil?
  end

  def refresh_ever_failed?
    not self.last_refresh_failure_at.nil?
  end

  def refresh_ever_completed?
    ever_successfully_refreshed? or refresh_ever_failed?
  end

  def refresh_status
    if refresh_failed?
      :failed
    elsif refreshing?
      :refreshing
    elsif ever_successfully_refreshed?
      :idle
    else
      :never
    end
  end

  def refreshing?
    request_ever_requested? and
      ( not refresh_ever_completed? or
          ( not ever_successfully_refreshed? or self.last_refreshed_at       < self.last_refresh_request_at ) and
          ( not refresh_ever_failed?         or self.last_refresh_failure_at < self.last_refresh_request_at ) )
  end

  # Did the last completed refresh fail?
  def refresh_failed?
    request_ever_requested? and
      refresh_ever_failed? and
      self.last_refresh_request_at < self.last_refresh_failure_at
  end

  # assume http protocol if no protocol identifier is present
  def url_with_protocol
    possibly_add_protocol self.url
  end

  # Used to uniquely reference DOM elements associated with this endpoint in CSS
  def css_class
    "endpoint-#{id}"
  end

  private
    def possibly_add_protocol(resource)
      if resource.include?(':')
        resource
      else
        "http://#{resource}"
      end
    end

    def good_url
      unless self.url.nil?
        uri = URI.parse(possibly_add_protocol(self.url))
        uri.kind_of?(URI::HTTP)
      else
        false
      end
    rescue URI::InvalidURIError
      errors.add(:url, 'is bad')
    end
end
