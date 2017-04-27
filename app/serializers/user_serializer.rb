class UserSerializer < ActiveModel::Serializer
  attributes :name, :id
  attribute :gravatar_url, key: :image do
    object.gravatar_url(50)
  end
  attribute :balance, if: :user_group? do
    object.user_groups_users
      .find_by_user_group_id(instance_options[:user_group]).balance.to_f
  end

  def user_group?
    instance_options[:user_group]
  end
end
