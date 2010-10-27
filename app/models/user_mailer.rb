class UserMailer < ActionMailer::Base
  def signup_notification(host, user)
    setup_email(host, user)
    @subject    += 'Please activate your new account'
  
    @body[:url]  = "http://#{host}/activate/#{user.activation_code}"
  
  end
  
  def activation(host, user)
    setup_email(host, user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = "http://#{host}/"
  end

  def reset_password(host, user)
    setup_email(host, user)
    @subject    += 'Reset password'
    @body[:url]  = "http://#{host}/change_password/#{user.reset_password_code}"
  end
  
  protected
    def setup_email(host, user)
      @recipients  = "#{user.email}"
      @from        = "support@tasawr.com"
      @subject     = "http://#{host} "
      @sent_on     = Time.now
      @body[:user] = user
    end
end
