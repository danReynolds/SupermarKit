class GroceriesItemsPayments < ApplicationRecord
  belongs_to :groceries_items
  belongs_to :payments
end
