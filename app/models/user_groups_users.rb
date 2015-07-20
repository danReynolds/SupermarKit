class UserGroupsUsers < ActiveRecord::Base
  validates_uniqueness_of :user_group_id, scope: :user_id
  belongs_to :user
  belongs_to :user_group

  INVITED = "invited".freeze
  ACCEPTED = "accepted".freeze

  STATES = [INVITED, ACCEPTED]
end
