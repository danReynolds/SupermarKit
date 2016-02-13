class User < ActiveRecord::Base
  validates :password, confirmation: true
  validates :password_confirmation, length: { minimum: 9 }, if: :new_record?
  validates :password_confirmation, presence: true, if: :new_record?
  validates :name, presence: true, uniqueness: true
  validates :email, uniqueness: true, presence: true

  has_many :requests, class_name: GroceriesItems, foreign_key: :requester_id
  has_many :user_groups_users, class_name: UserGroupsUsers
  has_many :user_groups, through: :user_groups_users
  has_many :items, through: :user_groups
  has_many :groceries, through: :user_groups
  belongs_to :default_group, class_name: 'UserGroup', foreign_key: :user_group_default_id

  acts_as_user roles: :admin

  authenticates_with_sorcery! do |config|
    config.authentications_class = Authentication
  end

  has_many :authentications, dependent: :destroy
  accepts_nested_attributes_for :authentications

  scope :with_name, ->(q) { where('users.name LIKE ?', "%#{q}%").distinct.order('name ASC') }

  def gravatar_url(size)
    gravatar = Digest::MD5::hexdigest(email).downcase
    url = "http://gravatar.com/avatar/#{gravatar}.png?s=#{size}"
  end
end
