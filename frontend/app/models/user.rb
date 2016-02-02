class User < ActiveRecord::Base
  has_secure_password

  has_many :endpoints

  validates :username, presence: true
  validates :password, presence: true

  validates_length_of :username, :mininum => 1, :maximum => 30
end
