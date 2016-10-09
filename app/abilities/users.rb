Canard::Abilities.for(:user) do
  can [:read, :auto_complete],                   User
  can :manage,                                   user
  can :view_email,                               User,                          id: @user.friends.ids

  can :create,                                   Grocery
  can :manage,                                   Grocery,                       user_group_id: @user.user_group_ids

  can :create,                                   UserGroup
  can :manage,                                   UserGroup,                     id: @user.user_group_ids

  can :create,                                   GroceryStore
  can :read,                                     GroceryStore

  can :create,                                   Item
  can :manage, Item, Item.all do |item|
    UserGroup.public.union(@user.user_groups).merge(item.user_groups).length.nonzero?
  end
  can :create,                                   Authentication
  can :manage,                                   Authentication,                user_id: @user.id
end
