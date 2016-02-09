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

  def ever_successfully_refreshed?
    not self.last_refreshed_at.nil?
  end

  def refreshing?
    not self.last_refresh_request_at.nil? and
      ( not ever_successfully_refreshed? or
          self.last_refreshed_at < self.last_refresh_request_at )
  end

  # assume http protocol if no protocol identifier is present
  def url_with_protocol
    possibly_add_protocol self.url
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
