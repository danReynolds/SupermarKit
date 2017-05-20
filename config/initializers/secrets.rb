include Secrets

class Application < Rails::Application
  config.before_initialize do
    load_secrets
  end
end
