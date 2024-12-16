require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Enable code reloading and avoid eager loading
  config.enable_reloading = true
  config.eager_load = false

  # Show full error reports
  config.consider_all_requests_local = true

  # Enable server timing for performance insights
  config.server_timing = true

  # Caching settings
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.cache_store = :memory_store
    config.public_file_server.headers = { "Cache-Control" => "public, max-age=#{2.days.to_i}" }
  else
    config.action_controller.perform_caching = false
    config.cache_store = :null_store
  end

  # Active Storage settings for file uploads
  config.active_storage.service = :local

  # Action Mailer settings
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.perform_caching = false
  config.action_mailer.default_url_options = { host: "localhost", port: 3000 }

  # Deprecation warnings and errors
  config.active_support.deprecation = :log
  config.active_support.disallowed_deprecation = :raise
  config.active_support.disallowed_deprecation_warnings = []

  # Migration and query logs
  config.active_record.migration_error = :page_load
  config.active_record.verbose_query_logs = true

  # Logging and asset handling
  config.assets.quiet = true
  config.action_view.annotate_rendered_view_with_filenames = true

  # Allow all hosts in development
  config.hosts.clear

   # Alternatively, explicitly allow specific hosts
  config.hosts << "localhost"
  config.hosts << "127.0.0.1"
  config.hosts << "harmoni.loca.lt" # Custom host for tunneling

  # Add custom host for local tunneling
  config.hosts << "harmoni.loca.lt"

  # Static files (e.g., public/manifest.json)
  config.public_file_server.enabled = true

  # Uncomment to allow Action Cable access from any origin
  # config.action_cable.disable_request_forgery_protection = true
end
