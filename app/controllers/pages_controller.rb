class PagesController < ApplicationController
  skip_authorization_check
  skip_before_action :require_login, raise: false

  def home
    File.write("test.txt", ENV["GOOGLE_KEY"])
    group = current_user.try(:default_group)

    if group
      redirect_to group.active_groceries.first || group
    elsif logged_in?
      redirect_to user_groups_path
    end
  end

  def about
  end

  def letsencrypt1
    render text: 'r5HDrACnaM2ybg60aqyLe_dEp12KUKF08dvxEqpB-EU.s20dhHv_2FQ191o8TybEHfK4j_N_p5wnIqM5QNARYus'
  end

  def letsencrypt2
    render text: 'aFTJ-03bQlZyNNyf6aEBqRbgq9V5zv30RstBfyj7RWg.s20dhHv_2FQ191o8TybEHfK4j_N_p5wnIqM5QNARYus'
  end

  def letsencrypt3
    render text: 'Xhf5BYHEqjCK80Kt7IXnM8c_u4XsZhhROQXgFOYPdlM.s20dhHv_2FQ191o8TybEHfK4j_N_p5wnIqM5QNARYus'
  end

  def letsencrypt4
    render text: 'GcKxDz-FUSVaVZPxS0usQ-D2pjx2oJLsEL4kapxOGns.s20dhHv_2FQ191o8TybEHfK4j_N_p5wnIqM5QNARYus'
  end
end
