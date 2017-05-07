class GroceriesItemsUsers < ApplicationRecord
  belongs_to :groceries_item
  belongs_to :user
end
