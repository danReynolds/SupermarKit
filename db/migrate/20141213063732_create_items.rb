class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
    	t.string :name
    	t.string :description
    	t.timestamps
    end
  	add_reference :items, :grocery, index: true
  end
end
