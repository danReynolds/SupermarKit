class AddCentsToItem < ActiveRecord::Migration
  def change
    add_column :items, :price_cents, :integer
  end
end
