class UserObserver < ActiveRecord::Observer

  def after_create(user)
    UserMailer.deliver_signup_notification(SsoSite.active_host(user.host_token), user)
  end

  def after_save(user)
    UserMailer.deliver_activation(SsoSite.active_host(user.host_token), user) if user.recently_activated?
    UserMailer.deliver_reset_password(SsoSite.active_host(user.host_token), user) if !user.reset_password_code.nil?
  end
end
