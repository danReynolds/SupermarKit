class UserPayment < ActiveRecord::Base
  belongs_to :user_group
  belongs_to :payee, class_name: User
  belongs_to :payer, class_name: User
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  monetize :price_cents
end
