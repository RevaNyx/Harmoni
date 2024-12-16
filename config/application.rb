require_relative "boot"

require "rails/all"
require "devise"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Harmoni
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # Specify directories to be ignored by autoloading and eager loading
    config.autoload_lib(ignore: %w[assets tasks])

    # Configure session store
    config.session_store :cookie_store, key: '_harmoni_session'

    # Middleware configuration for sessions and cookies
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore

    # Configuration for the application, engines, and railties goes here.
    # These settings can be overridden in specific environments.
  end
end
