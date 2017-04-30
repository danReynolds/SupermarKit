class ConsolidatePaymentsBetweenTwoUsers < ActiveRecord::Migration[5.0]
  def change
    add_reference :user_payments, :grocery
    rename_table :user_payments, :payments
    drop_table :grocery_payments
  end
end
