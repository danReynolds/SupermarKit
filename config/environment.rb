# Load the Rails application.
require_relative 'application'

ActionMailer::Base.smtp_settings = {
  user_name: ENV["MAILER_USER"],
  password: ENV["MAILER_PASSWORD"],
  domain: ENV["MAILER_DOMAIN"],
  address: ENV["MAILER_ADDRESS"],
  port: 587,
  authentication: :plain,
  enable_starttls_auto: true
}

# Initialize the Rails application.
Rails.application.initialize!
