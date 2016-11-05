class AddEnabledToSlackMessage < ActiveRecord::Migration
  def change
    add_column :slack_messages, :enabled, :boolean, default: false
  end
end
