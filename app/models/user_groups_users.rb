class UserGroupsUsers < ApplicationRecord
  validates_uniqueness_of :user_group_id, scope: :user_id
  belongs_to :user
  belongs_to :user_group

  INVITED = "invited".freeze
  ACCEPTED = "accepted".freeze

  STATES = [INVITED, ACCEPTED]

  def balance
    query = "
      SELECT IFNULL(
        (
          SELECT SUM(payments.price_cents) FROM payments
          LEFT JOIN groceries ON groceries.id = payments.grocery_id
          WHERE payments.payee_id = #{user.id}
          AND (
            groceries.user_group_id = #{user_group.id}
            OR payments.user_group_id = #{user_group.id}
          )
        ), 0
      ) - (
        SELECT IFNULL(
          (
            SELECT SUM(payments.price_cents) FROM payments
            LEFT JOIN groceries ON groceries.id = payments.grocery_id
            WHERE payments.payer_id = #{user.id}
            AND (
              groceries.user_group_id = #{user_group.id}
              OR payments.user_group_id = #{user_group.id}
            )
          ), 0
        )
      )
    "
    Money.new(ActiveRecord::Base.connection.execute(query).to_a.first.first)
  end
end
