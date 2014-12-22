class UserGroup < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_many :items, through: :users
  has_many :groceries, through: :users

  validates :name, presence: true, uniqueness: true
end
