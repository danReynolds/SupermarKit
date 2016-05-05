class PagesController < ApplicationController
  skip_authorization_check
  skip_before_filter :require_login

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

  def letsencrypt
    render text: 'PQCzrmElcTJC87Jkfst2EviZkZmb6u7NpBSjoeELLss.s20dhHv_2FQ191o8TybEHfK4j_N_p5wnIqM5QNARYus'
  end

  def letsencrypt2
    render text: 'd3H5G7hBqfmjacHT_D6VVyK74ucNPxfdFuoAuUUm3g0.s20dhHv_2FQ191o8TybEHfK4j_N_p5wnIqM5QNARYus'
  end
end
