class UserMailer < ActionMailer::Base
  default from: 'us@supermarkit.ca'

  def reset_password_email(user)
    @user = user
    @url  = edit_password_reset_url(user.reset_password_token)
    mail(:to => user.email, :subject => "Your password has been reset")
  end

  def activation_needed_email(user)
    @user = user
    @url = activate_user_path(@user)
    mail( to: @user.email, subject: 'Join Supermarkit' )
  end

  def activation_success_email(user)
    @user = user
    @url = activate_user_path(@user)
    mail( to: @user.email, subject: 'Shop with Supermarkit' )
  end
end
