class AddReasontoUserPayments < ActiveRecord::Migration
  def change
    add_column :user_payments, :reason, :string
  end
end
