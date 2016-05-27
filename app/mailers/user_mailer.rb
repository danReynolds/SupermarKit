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

  def send_grocery_list_email(user, grocery, message = nil)
    @user = user
    @grocery = grocery
    @valid_recipes = @grocery.recipes.includes(:items).select do |recipe|
      (recipe.items & @grocery.items).length.nonzero?
    end
    @message = message
    mail(to: format_recipient(@user), subject: "Groceries For #{@grocery.name}")
  end

private
  def format_recipient(user)
    "#{user.name} <#{user.email}>"
  end
end
