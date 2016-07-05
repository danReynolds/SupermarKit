class SeparateGroceryPayments < ActiveRecord::Migration
  def up
    create_table :grocery_payments do |t|
      t.integer :grocery_id
      t.integer :user_id
      t.integer :price_cents
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

    Payment.all.each do |payment|
      GroceryPayment.create(
        grocery_id: payment.grocery_id,
        user_id: payment.user_id,
        price_cents: payment.price_cents
      )
    end

    drop_table :payments
  end

  def down
  end
end
