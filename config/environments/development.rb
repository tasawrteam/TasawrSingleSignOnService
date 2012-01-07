# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false
config.action_mailer.default_url_options = {:host => 'servicedev1.net'}

if defined?(ActionController)
  ActionController::Base.session = {
    :key         => '_tasawr_sso_session',
    :secret      => 'f11cf195514c9f70d208c7860c97b77b2f2fa19cc1b7291d00e26c89530a75077146bc9f0ec4076af5c5fe9b74ec1a9a3de6158a1840712d801103022417cf67',
    :domain      => '.servicedev1.net'
  }
end

HRM_URL = 'http://hrm.tasawr.com'
WIKI_URL = 'http://wiki.tasawr.com/home?do=login'
ISSUE_URL = 'http://issues.tasawr.com'
COLLAB_URL = 'http://collab.tasawr.com'
SUPPORT_URL = 'http://support.tasawr.com/scp'
