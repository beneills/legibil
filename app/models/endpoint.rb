class Endpoint < ActiveRecord::Base
  belongs_to :user

  validates :url,  presence: true
  validates :name, presence: true
  validates :user, presence: true

  validates_length_of :name, :mininum => 1, :maximum => 30
end
