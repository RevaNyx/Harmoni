source "https://rubygems.org"

# Core dependencies
gem "rails", "~> 7.2.2"
gem "pg", "~> 1.1"                           # Use PostgreSQL as the database
gem "puma", ">= 5.0"                         # Web server for Rails
gem "sprockets-rails"                        # Asset compilation for Rails
gem 'mini_racer'                      
# JavaScript & Hotwire
gem "importmap-rails"                        # ESM import maps for JavaScript
gem "turbo-rails"                            # Hotwire's SPA-like page accelerator
gem "stimulus-rails"                         # Hotwire's JavaScript framework

# JSON API
gem "jbuilder"                               # Build JSON APIs with ease

# Styling and frontend
gem "bootstrap", "~> 5.3"                    # Bootstrap for UI components
gem "sassc-rails", "~> 2.1"                  # SCSS for stylesheets

# Authentication & OAuth
gem "devise", "~> 4.9"                       # User authentication
gem "omniauth-rails_csrf_protection", "~> 1.0.0" # CSRF protection for OmniAuth
gem "cronofy"                                # Cronofy API client
gem "omniauth-cronofy"                       # OmniAuth strategy for Cronofy

# Environment variables
gem "dotenv-rails", groups: [:development, :test] # Load environment variables from `.env`

# Utilities
gem "ostruct"                                # Simple data objects
gem "tzinfo-data", platforms: %i[windows jruby]   # Timezone data for Windows
gem "bootsnap", require: false               # Reduces boot times through caching

# Optional features (uncomment if needed)
# gem "redis", ">= 4.0.1"                    # Use Redis adapter for Action Cable
# gem "bcrypt", "~> 3.1.7"                   # Secure passwords for Active Model
# gem "image_processing", "~> 1.2"           # Active Storage variants

# Development and testing
group :development, :test do
  gem "debug", platforms: %i[mri windows], require: "debug/prelude" # Debugging
  gem "brakeman", require: false                                   # Security scanner
  gem "rubocop-rails-omakase", require: false                      # Ruby style checker
end

group :development do
  gem "web-console"                          # Console on exception pages
end

group :test do
  gem "capybara"                             # System testing
  gem "selenium-webdriver"                   # Web driver for testing
end