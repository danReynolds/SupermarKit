class AddDefaultToPriceCents < ActiveRecord::Migration
  def change
    change_column :groceries_items, :price_cents, :integer, default: 0
  end
end
