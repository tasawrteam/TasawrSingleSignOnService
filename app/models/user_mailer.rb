class UserMailer < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    @subject    += 'Please activate your new account'
  
    @body[:url]  = "http://connect.tasawr.info/activate/#{user.activation_code}"
  
  end
  
  def activation(user)
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = "http://connect.tasawr.info/"
  end

  def reset_password(user)
    setup_email(user)
    @subject    += 'Reset password'
    @body[:url]  = "http://connect.tasawr.info/change_password/#{user.reset_password_code}"
  end
  
  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = "support@tasawr.com"
      @subject     = "http://connect.tasawr.info "
      @sent_on     = Time.now
      @body[:user] = user
    end
end
