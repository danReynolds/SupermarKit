class AddSlackMessageToSlackBot < ActiveRecord::Migration
  def change
    remove_column :slack_bots, :format
    create_table :slack_messages do |t|
      t.string :format
      t.string :message_type
    end
    add_reference :slack_messages, :slack_bot
  end
end
