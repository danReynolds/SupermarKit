class CreateSlackBot < ActiveRecord::Migration
  def change
    create_table :slack_bots do |t|
      t.string :api_token
    end
    add_reference :slack_bots, :user_group
  end
end
