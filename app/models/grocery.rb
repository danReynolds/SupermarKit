class Grocery < ActiveRecord::Base
  validates :name, presence: true
	has_and_belongs_to_many :items
  belongs_to :user
end
