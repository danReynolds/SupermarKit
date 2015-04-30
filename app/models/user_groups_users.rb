class UserGroupsUsers < ActiveRecord::Base
  INVITED = "invited".freeze
  ACCEPTED = "accepted".freeze

  STATES = [INVITED, ACCEPTED]
  
  belongs_to :user
  belongs_to :user_group
end
