class UserMailer < ActionMailer::Base
  default from: 'us@supermarkit.ca'

  def activation_needed_email(user)
    @user = user
    @url = activate_user_url(@user)
    mail(to: @user.email, subject: 'Join Supermarkit')
  end

  def activation_success_email(user)
    @user = user
    @url = activate_user_url(@user)
    mail(to: @user.email, subject: 'Shop with Supermarkit')
  end

  def send_grocery_list_email(user, grocery)
    @user = user
    @grocery = grocery
    mail(to: @user.email, subject: "Groceries For #{@grocery.name}")
  end
end
