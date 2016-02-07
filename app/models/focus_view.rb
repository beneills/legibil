class FocusView < ActiveRecord::Base
  belongs_to :endpoint

  has_attached_file :focus_area, default_url: "/images/:style/missing.png"
  validates_with AttachmentContentTypeValidator, attributes: :focus_area, content_type: /\Aimage\/.*\Z/
  validates_with AttachmentSizeValidator,        attributes: :focus_area, less_than: 1.megabytes
end
