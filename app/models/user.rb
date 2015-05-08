class User < ActiveRecord::Base
  validates :password, confirmation: true
  validates :password_confirmation, length: { minimum: 3 }, if: :new_record?
  validates :password_confirmation, presence: true, if: :new_record?
  validates :name, presence: true, uniqueness: true
  validates :email, uniqueness: true, presence: true

  has_many :user_groups_users, class_name: UserGroupsUsers
  has_many :user_groups, through: :user_groups_users
  has_many :items, through: :user_groups
  has_many :groceries, through: :user_groups
  has_one :default_group, class_name: 'UserGroup', foreign_key: :user_group_default_id

  acts_as_user roles: :admin

  authenticates_with_sorcery! do |config|
    config.authentications_class = Authentication
  end

  has_many :authentications, dependent: :destroy
  accepts_nested_attributes_for :authentications

  scope :with_name, ->(q) { where('users.name LIKE ?', "%#{q}%").distinct }
end
