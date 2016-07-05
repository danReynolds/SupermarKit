class GroceryPayment < Payment
  belongs_to :user
  belongs_to :grocery
  validates_uniqueness_of :grocery_id, scope: :user_id
end
