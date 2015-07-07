Canard::Abilities.for(:user) do
  can [:read, :auto_complete],                   User
  can :manage,                                   user

  can :create,                                   Grocery
  can :manage,                                   Grocery,                         user_group_id: @user.user_group_ids

  can :create,                                   UserGroup
  can :manage,                                   UserGroup,                       id: @user.user_group_ids

  can :create,                                   Item
  can :manage,                                   Item,                            id: @user.user_groups.flat_map(&:privacy_items).uniq.map(&:id)

  can :create,                                   Authentication
  can :manage,                                   Authentication,                  user_id: @user.id
end
