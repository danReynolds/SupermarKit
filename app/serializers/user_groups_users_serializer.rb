class UserGroupsUsersSerializer < ActiveModel::Serializer
  attributes :id, :state
  attribute :balance, if: :user_group? do
    object.balance.to_f
  end

  def user_group?
    instance_options[:user_group]
  end
end
