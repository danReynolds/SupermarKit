class User < ActiveRecord::Base
  authenticates_with_sorcery!
  validates :password, length: { minimum: 3 }
  validates :password, confirmation: true
  validates :password_confirmation, presence: true

  validates :name, presence: true
  validates :email, uniqueness: true

  has_many :groceries
  has_many :items, through: :groceries
  has_and_belongs_to_many :user_groups

  scope :with_name, ->(q) { where('users.name LIKE ?', "%#{q}%").distinct }
end
