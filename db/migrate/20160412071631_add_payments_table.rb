class AddPaymentsTable < ActiveRecord::Migration
  def up
    create_join_table :users, :groceries, { index: true, table_name: :payments }
    add_column :payments, :price_cents, :integer, default: 0
  end

  def down
    drop_table :payments
  end
end
