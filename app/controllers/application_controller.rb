# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include FacebookConnectHelper

  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :fb_sig_friends, :password

  include ApplicationHelper
  include SsoSitesHelper

  before_filter :override_cookie_host_by_request_host
  before_filter :detect_sso_site
  
end


