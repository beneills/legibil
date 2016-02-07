class FocusView < ActiveRecord::Base
  belongs_to :endpoint

  has_attached_file :focus_area, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :focus_area, content_type: /\Aimage\/.*\Z/
end
