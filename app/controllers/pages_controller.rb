class PagesController < ApplicationController
  skip_authorization_check
  skip_before_action :require_login, raise: false

  def home
    group = current_user.try(:default_group)

    if group
      redirect_to group.active_groceries.first || group
    elsif logged_in?
      redirect_to user_groups_path
    end
  end

  def about
  end

  def letsencrypt
    render text: 'ZKgRmh-wMxWQnIZ3NrzfKal27RAzTl1DLhuWiWdFz8c.s20dhHv_2FQ191o8TybEHfK4j_N_p5wnIqM5QNARYus'
  end
end
