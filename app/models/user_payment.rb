class UserPayment < ActiveRecord::Base
  belongs_to :user_group
  has_one :payee, class_name: User
  has_one :payer, class_name: User
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  monetize :price_cents
end
