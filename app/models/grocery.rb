class Grocery < ActiveRecord::Base
  validates :name, presence: true
	has_and_belongs_to_many :items
  has_and_belongs_to_many :users
  belongs_to :owner, class_name: 'User'
end
