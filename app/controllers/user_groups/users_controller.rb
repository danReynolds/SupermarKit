class UserGroups::UsersController < ApplicationController
  include SplitController
  include ActiveModelSerializers
  initialize_split_controller :user_group

  def show
    render json: @user_group.users, user_group: @user_group
  end
end
