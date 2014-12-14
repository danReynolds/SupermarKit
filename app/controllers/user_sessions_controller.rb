class UserSessionsController < ApplicationController
  skip_before_filter :require_login, except: [:destroy]

  def new
    @user = User.new
  end

  def create
    if @user = login(params[:session][:email], params[:session][:password])
      redirect_back_or_to @user, notice: "Hey Softie #{@user.name}"
    else
      flash.now[:alert] = 'Come on man. Remember your shit.'
      render action: 'new'
    end
  end

  def destroy
    logout
    redirect_to root_path, notice: 'Successfully logged out.'
  end

private
end