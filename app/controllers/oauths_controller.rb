class OauthsController < ApplicationController
  skip_authorization_check
  skip_before_action :require_login, raise: false

  def oauth
    login_at(auth_params[:provider])
  end

  def callback
    provider = auth_params[:provider]

    begin
      if @user = login_from(provider)
        flash[:notice] = "Welcome back #{@user.name}"
        redirect_back(fallback_location: root_path)
      else
        @user = create_from(provider)
        @user.activate!

        reset_session # protect from session fixation attack
        auto_login(@user)
        redirect_to user_groups_path, notice: "Welcome #{@user.name}! Start by creating your first Kit with the people you want to shop with."
      end
    rescue Exception => e
      if e.class == ActiveRecord::RecordNotUnique
        message = "An account has already been made with your #{provider.humanize} email. Try a different login method."
      else
        message = "Our fault! We're unable to create a user with your #{provider.humanize} account."
      end
      flash[:notice] = message
      redirect_to login_path
    end
  end
end

private

def auth_params
  params.permit(:code, :provider)
end
