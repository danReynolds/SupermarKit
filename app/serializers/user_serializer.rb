class UserSerializer < ActiveModel::Serializer
  attributes :name, :id
  attribute :gravatar_url, key: :image do
    object.gravatar_url(50)
  end
  attribute :balance, if: :with_balance? do
    object.user_groups_users
      .find_by_user_group_id(instance_options[:with_balance]).balance.to_f
  end

  def with_balance?
    instance_options[:with_balance]
  end
end
