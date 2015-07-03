class UserGroup < ActiveRecord::Base
  has_many :user_groups_users, class_name: UserGroupsUsers
  has_many :users, through: :user_groups_users
  has_many :items, -> { uniq }, through: :groceries
  has_many :groceries

  validates :name, presence: true

  PUBLIC = 'public'.freeze
  PRIVATE = 'private'.freeze
  PRIVACY = [PUBLIC, PRIVATE]
  EMBLEMS = ['apple', 'banana', 'cheese', 'fish', 'meal', 'veggie', 'watermelon'].freeze

  def self.public
    UserGroup.where(privacy: PUBLIC)
  end

  def self.private
    UserGroup.where(privacy: PRIVATE)
  end

  def privacy_items
    if privacy == PUBLIC
      Item.where(id: UserGroup.public.flat_map(&:item_ids))
    else
      items
    end
  end

  def active_groceries
    groceries.where(finished_at: nil)
  end

  def finished_groceries
    groceries.where.not(finished_at: nil)
  end

  def accepted_users
    user_groups_users.where(state: UserGroupsUsers::ACCEPTED).map(&:user)
  end

  def user_state(user)
    user_groups_users.find_by_user_id(user.id).state
  end
end
