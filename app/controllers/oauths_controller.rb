class OauthsController < ApplicationController
  skip_authorization_check
  skip_before_action :require_login, raise: false

  def oauth
    login_at(auth_params[:provider])
  end

  def callback
    provider = auth_params[:provider]

    begin
      unless login_from(provider)
        user_hash = sorcery_fetch_user_hash(provider).with_indifferent_access

        unless @user = User.find_by_email(user_hash[:user_info][:email])
          @user = create_from(provider)
          @user.activate!
          notice = "Welcome #{@user.name}! Start by creating your first Kit with the people you want to shop with."
        end

        reset_session # protect from session fixation attack
        auto_login(@user)
        flash[:notice] = notice
      end
      redirect_to root_path
    rescue Exception => e
      redirect_to login_path, notice: "Our fault! We're unable to create a user with your #{provider.humanize} account."
    end
  end
end

private

def auth_params
  params.permit(:code, :provider)
end
