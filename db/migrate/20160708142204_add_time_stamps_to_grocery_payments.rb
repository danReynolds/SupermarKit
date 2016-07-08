class AddTimeStampsToGroceryPayments < ActiveRecord::Migration
  def change
    change_table :grocery_payments do |t|
      t.timestamps
    end
  end
end
