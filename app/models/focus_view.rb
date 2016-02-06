class FocusView < ActiveRecord::Base
  belongs_to :endpoint

  has_attached_file :screenshot, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :screenshot, content_type: /\Aimage\/.*\Z/
end
