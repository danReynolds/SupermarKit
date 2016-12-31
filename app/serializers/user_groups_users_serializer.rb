class UserGroupsUsersSerializer < ActiveModel::Serializer
  attributes :id, :state
  attribute :balance, if: :with_balance? do
    object.balance.to_f
  end

  def with_balance?
    instance_options[:with_balance]
  end
end
