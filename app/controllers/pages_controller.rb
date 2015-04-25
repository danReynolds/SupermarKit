class PagesController < ApplicationController
  skip_authorization_check
  skip_before_filter :require_login

  def home
    active_grocery = current_user.default_group.active_groceries.first if current_user && current_user.default_group
    redirect_to active_grocery if active_grocery
  end

  def about
  end
end
