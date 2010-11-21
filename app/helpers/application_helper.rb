# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def authorize
    logged_in? && current_user.admin?
  end

  def detect_test_site
    if request.host.match(/\.info/)
      @domain_suffix = '.info'
    else
      @domain_suffix = '.net'
    end
  end

end

