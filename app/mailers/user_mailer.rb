class UserMailer < ActionMailer::Base
  default from: 'folks@supermarkit.io'

  def activation_needed_email(user)
    @user = user
    @url = activate_user_url(@user)
    mail(to: format_recipient(@user), subject: 'Join SupermarKit')
  end

  def activation_success_email(user)
    @user = user
    @url = activate_user_url(@user)
    mail(to: format_recipient(@user), subject: 'Shop with SupermarKit')
  end

  def send_grocery_list_email(user, grocery)
    @user = user
    @grocery = grocery
    mail(to: format_recipient(@user), subject: "Groceries For #{@grocery.name}")
  end

private
  def format_recipient(user)
    "#{user.name} <#{user.email}>"
  end
end
