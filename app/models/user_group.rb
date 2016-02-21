class UserGroup < ActiveRecord::Base
  has_many :user_groups_users, class_name: UserGroupsUsers
  has_many :users, through: :user_groups_users
  has_many :items, -> { uniq }, through: :groceries
  has_many :groceries
  has_many :user_defaults, class_name: 'User', foreign_key: :user_group_default_id
  has_attached_file :banner, styles: { large: '800x600>', standard: '600x450>' }, default_url: 'user_groups/default3.jpg'

  validates_attachment :banner, content_type: { content_type: /\Aimage\/.*\Z/ }
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

  def format_users
    user_groups_users.map do |user_group_user, h|
      {
        id: user_group_user.user_id,
        name: user_group_user.user.name,
        state: user_group_user.state,
        gravatar: user_group_user.user.gravatar_url(50)
      }
    end
  end
end
