class UserMailerPreview < ActionMailer::Preview
  def activation_needed_preview
    UserMailer.activation_needed_email(User.last)
  end

  def activation_success_preview
    UserMailer.activation_success_email(User.last)
  end

  def send_grocery_list_preview
    grocery = Grocery.all.lazy.detect { |g| g.recipes.length.nonzero? && g.items.length.nonzero? }
    UserMailer.send_grocery_list_email(User.last, grocery, 'test message')
  end
end
