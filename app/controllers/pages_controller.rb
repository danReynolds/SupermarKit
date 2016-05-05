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
    render text: 'q6Icrz2EFK6mjcV3TIHuF_-YcIPR_EUwLJ3G3sTJlNk.s20dhHv_2FQ191o8TybEHfK4j_N_p5wnIqM5QNARYus'
  end
end
