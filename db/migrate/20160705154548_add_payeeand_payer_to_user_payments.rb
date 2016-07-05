class AddPayeeandPayerToUserPayments < ActiveRecord::Migration
  def change
    remove_column :user_payments, :user_id
    add_column :user_payments, :payee_id, :integer
    add_column :user_payments, :payer_id, :integer
  end
end
