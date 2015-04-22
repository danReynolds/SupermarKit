class PagesController < ApplicationController
  skip_authorization_check
  skip_before_filter :require_login

  def home
    active_grocery = current_user.default_group.active_groceries.first if current_user
    redirect_to current_user.default_group.active_groceries.first if active_grocery
  end

  def about
  end
end