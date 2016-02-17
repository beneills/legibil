class ColourView < ActiveRecord::Base
  belongs_to :endpoint

  has_attached_file :palette,
    url: "/images/:hash-:filename",
    default_url: "/images/:style/missing.png",
    hash_secret: Rails.application.secrets.paperclip_hash_secret
  validates_with AttachmentContentTypeValidator, attributes: :palette, content_type: /\Aimage\/.*\Z/
  validates_with AttachmentSizeValidator,        attributes: :palette, less_than: 1.megabytes
end
