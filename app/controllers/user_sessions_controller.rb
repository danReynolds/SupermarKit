class UserSessionsController < ApplicationController
  skip_before_action :require_login, except: [:destroy], raise: false
  skip_authorization_check

  def new
  end

  def create
    if @user = login(session_params[:email], session_params[:password])
      redirect_back_or_to root_path
    else
      render json: 'Incorrect login information.', status: :unprocessable_entity
    end
  end

  def destroy
    logout
    redirect_to login_path
  end

  private

  def session_params
    params.require(:user_session).permit(:email, :password)
  end
end
