# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include FacebookConnectHelper
  include ApplicationHelper
  include SsoSitesHelper
  include MultidomainCookieHelper

  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :fb_sig_friends, :password

  before_filter :set_cookie_domain
  before_filter :detect_sso_site
  
end


