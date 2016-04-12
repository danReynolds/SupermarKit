class AddPaymentsTable < ActiveRecord::Migration
  def change
    create_join_table :users, :groceries, { index: true, table_name: :payments }
    add_column :payments, :price_cents, :integer, default: 0
  end
end
