class RemoveStiNotAppropriate < ActiveRecord::Migration
  def change
    drop_table :payments
    add_column :grocery_payments, :price_cents, :integer, default: 0
    add_column :user_payments, :price_cents, :integer, default: 0
    add_index :user_payments, :payee_id
    add_index :user_payments, :payer_id
  end
end
