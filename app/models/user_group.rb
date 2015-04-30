class UserGroup < ActiveRecord::Base
  has_many :user_groups_users, class_name: UserGroupsUsers
  has_many :users, through: :user_groups_users
  has_many :items, -> { uniq }, through: :groceries
  has_many :groceries

  validates :name, presence: true

  def active_groceries
    groceries.where(finished_at: nil)
  end

  def finished_groceries
    groceries.where.not(finished_at: nil)
  end
end
