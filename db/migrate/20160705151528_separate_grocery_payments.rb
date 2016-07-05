class SeparateGroceryPayments < ActiveRecord::Migration
  def change
    create_table :grocery_payments do |t|
      t.integer :grocery_id
      t.integer :user_id
    end

    add_index :grocery_payments, [:user_id, :grocery_id], unique: true
    add_index :grocery_payments, :grocery_id

    create_table :user_payments do |t|
      t.integer :user_group_id
      t.integer :user_id
    end

    add_index :user_payments, [:user_id, :user_group_id], unique: true
    add_index :user_payments, :user_group_id

    Payment.all.each do |payment|
      GroceryPayment.create(
        grocery_id: payment.grocery_id,
        user_id: payment.user_id,
        price_cents: payment.price_cents
      )
      payment.destroy
    end

    add_column :payments, :type, :string
    remove_index :payments, column: [:grocery_id]
    remove_index :payments, column: [:user_id, :grocery_id]
    remove_column :payments, :user_id
    remove_column :payments, :grocery_id
  end
end
