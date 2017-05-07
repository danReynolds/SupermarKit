class Payment < ApplicationRecord
  belongs_to :user_group
  belongs_to :grocery
  belongs_to :payee, class_name: User
  belongs_to :payer, class_name: User
  has_many :items, through: :groceries_items
  has_and_belongs_to_many :groceries_items, class_name: GroceriesItems

  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates_presence_of :payee, :payer, :user_group
  monetize :price_cents
end
