class AddPaymentsTable < ActiveRecord::Migration
  def up
    create_table :payments do |t|
      t.integer :grocery_id
      t.integer :user_id
    end
    
    add_index :payments, [:user_id, :grocery_id], unique: true
    add_index :payments, :grocery_id
    add_column :payments, :price_cents, :integer, default: 0
  end

  def down
    drop_table :payments
  end
end
