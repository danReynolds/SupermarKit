class UserPayment < Payment
  belongs_to :user
  belongs_to :user_group
  validates_uniqueness_of :user_group_id, scope: :user_id
end
