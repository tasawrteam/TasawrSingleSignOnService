# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def override_cookie_host_by_request_host
    host = request.host
    host_parts = host.split(/\./)
    host = host_parts[(host_parts.length - 2)..(host_parts.length)].join('.')
    ActionController::Session::CookieStore.override_domain = ".#{host}"
    ActionController::Session::AbstractStore.override_domain = ".#{host}"
  end

end

