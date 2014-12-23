class UserGroup < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_many :items, through: :groceries
  has_many :groceries

  validates :name, presence: true, uniqueness: true
end
