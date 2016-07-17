class AddReceiptToGrocery < ActiveRecord::Migration
  def change
      add_attachment :groceries, :receipt
  end
end
