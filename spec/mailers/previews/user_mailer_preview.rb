class UserMailerPreview < ActionMailer::Preview
  def activation_needed_preview
    UserMailer.activation_needed_email(User.last)
  end

  def activation_success_preview
    UserMailer.activation_success_email(User.last)
  end

  def send_grocery_list_preview
    UserMailer.send_grocery_list_email(User.last, Grocery.last)
  end
end
