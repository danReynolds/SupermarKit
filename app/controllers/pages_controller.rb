class PagesController < ApplicationController
  skip_authorization_check
  skip_before_action :require_login, raise: false

  def home
    File.write("test.txt", ENV["GOOGLE_CALLBACK"])
    group = current_user.try(:default_group)

    if group
      redirect_to group.active_groceries.first || group
    elsif logged_in?
      redirect_to user_groups_path
    end
  end

  def about
  end
end
