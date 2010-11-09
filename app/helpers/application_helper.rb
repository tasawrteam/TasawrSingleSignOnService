# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def authorize
    logged_in? && current_user.admin?
  end

end

