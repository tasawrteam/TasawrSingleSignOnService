# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
config.action_view.cache_template_loading            = true

# See everything in the log (default is :info)
# config.log_level = :debug

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Use a different cache store in production
# config.cache_store = :mem_cache_store

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false

# Enable threaded mode
# config.threadsafe!

config.action_mailer.default_url_options = {:host => 'connect.tasawr.info'}

require 'smtp-tls'

config.action_mailer.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
    :address => "smtp.gmail.com",
    :port => 587,
    :domain => "tasawr.com",
    :user_name => "tasawr.net@tasawr.com",
    :password => "abc1234",
    :authentication => :plain,
    :enable_starttls_auto => true
}


if defined?(ActionController)
  ActionController::Base.session = {
    :key         => '_tasawr_sso_session',
    :secret      => 'f11cf195514c9f70d208c7860c97b77b2f2fa19cc1b7291d00e26c89530a75077146bc9f0ec4076af5c5fe9b74ec1a9a3de6158a1840712d801103022417cf67',
    :domain      => '.tasawr.info'
  }
end