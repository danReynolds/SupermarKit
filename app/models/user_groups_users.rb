class UserGroupsUsers < ActiveRecord::Base
  validates_uniqueness_of :user_group_id, scope: :user_id
  belongs_to :user
  belongs_to :user_group

  INVITED = "invited".freeze
  ACCEPTED = "accepted".freeze

  STATES = [INVITED, ACCEPTED]

  def balance
    query = "
      SELECT SUM(
        (CONTRIBUTIONS_WITH_USER.TOTAL_PAYMENT / CONTRIBUTIONS_WITH_USER.CONTRIBUTOR_COUNT)  - CONTRIBUTIONS_WITH_USER.PAYMENT
      )
      FROM
      (
        SELECT
        TOTAL_PAYMENT,
        CONTRIBUTOR_COUNT,
        PAYMENT
        FROM (
          SELECT payments.grocery_id AS CONTRIBUTOR_GROCERY,
          COUNT(payments.grocery_id) as CONTRIBUTOR_COUNT,
          SUM(payments.price_cents) as TOTAL_PAYMENT
          FROM payments WHERE payments.grocery_id IN (
            SELECT DISTINCT groceries.id FROM groceries
            INNER JOIN payments ON groceries.id = payments.grocery_id
            AND payments.user_id = #{user.id}
          )
          GROUP BY payments.grocery_id
        ) CONTRIBUTIONS INNER JOIN
        (
          SELECT payments.grocery_id AS USER_GROCERY,
          payments.price_cents AS PAYMENT
          FROM payments WHERE payments.user_id = #{user.id}
        ) USER_CONTRIBUTIONS ON CONTRIBUTIONS.CONTRIBUTOR_GROCERY = USER_CONTRIBUTIONS.USER_GROCERY
      ) CONTRIBUTIONS_WITH_USER
    "
    Money.new(ActiveRecord::Base.connection.execute(query).to_a.first.first)
  end
end
