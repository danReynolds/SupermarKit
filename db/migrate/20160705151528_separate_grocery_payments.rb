class SeparateGroceryPayments < ActiveRecord::Migration
  def up
    create_table :grocery_payments do |t|
      t.integer :grocery_id
      t.integer :user_id
      t.integer :price_cents
      t.timestamps
    end

    add_index :grocery_payments, [:user_id, :grocery_id], unique: true
    add_index :grocery_payments, :grocery_id

    create_table :user_payments do |t|
      t.integer :price_cents
      t.timestamps
    end

    add_reference :user_payments, :payer, index: true
    add_reference :user_payments, :payee, index: true
    add_reference :user_payments, :user_group, index: true

    drop_table :payments
  end

  def down
  end
end
