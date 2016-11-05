class AddFormatToSlackBot < ActiveRecord::Migration
  def change
    add_column :slack_bots, :format, :string
  end
end
