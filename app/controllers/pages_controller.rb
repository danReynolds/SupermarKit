class PagesController < ApplicationController
  skip_authorization_check
  skip_before_action :require_login, raise: false

  def home
    group = current_user.try(:default_group)

    if group && grocery = group.active_groceries.first
      redirect_to grocery
    elsif current_user
      redirect_to user_groups_path
    end
  end

  def about
  end
end
