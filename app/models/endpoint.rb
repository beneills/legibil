require 'uri'

class Endpoint < ActiveRecord::Base
  belongs_to :user

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

  private
    def good_url
      uri = URI.parse(self.url)
      uri.kind_of?(URI::HTTP)
    rescue URI::InvalidURIError
      errors.add(:url, 'is bad')
    end
end
