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
        SUM(
          (CONTRIBUTIONS_WITH_USER.TOTAL_PAYMENT / CONTRIBUTIONS_WITH_USER.CONTRIBUTOR_COUNT) - CONTRIBUTIONS_WITH_USER.PAYMENT
        ), 0) - (
          SELECT IFNULL(SUM(user_payments.price_cents), 0) FROM user_payments
          WHERE user_payments.payer_id = #{user.id}
          AND user_payments.user_group_id = #{user_group.id}
        ) + (
          SELECT IFNULL(SUM(user_payments.price_cents), 0) FROM user_payments
          WHERE user_payments.payee_id = #{user.id}
          AND user_payments.user_group_id = #{user_group.id}
        )
        FROM
        (
          SELECT
          TOTAL_PAYMENT,
          CONTRIBUTOR_COUNT,
          PAYMENT
          FROM (
            SELECT grocery_payments.grocery_id AS CONTRIBUTOR_GROCERY,
            COUNT(grocery_payments.grocery_id) as CONTRIBUTOR_COUNT,
            SUM(grocery_payments.price_cents) as TOTAL_PAYMENT
            FROM grocery_payments WHERE grocery_payments.grocery_id IN (
              SELECT DISTINCT groceries.id FROM groceries
              INNER JOIN grocery_payments ON groceries.id = grocery_payments.grocery_id
              AND grocery_payments.user_id = #{user.id}
              WHERE groceries.user_group_id = #{user_group.id}
            )
            GROUP BY grocery_payments.grocery_id
          ) CONTRIBUTIONS INNER JOIN
          (
            SELECT grocery_payments.grocery_id AS USER_GROCERY,
            grocery_payments.price_cents AS PAYMENT
            FROM grocery_payments WHERE grocery_payments.user_id = #{user.id}
          ) USER_CONTRIBUTIONS ON CONTRIBUTIONS.CONTRIBUTOR_GROCERY = USER_CONTRIBUTIONS.USER_GROCERY
        ) CONTRIBUTIONS_WITH_USER
    "
    Money.new(ActiveRecord::Base.connection.execute(query).to_a.first.first)
  end
end
