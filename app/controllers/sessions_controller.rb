# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem

  layout 'basic'
  before_filter :check_facebook_connect_session, :only => [:new]
  before_filter :check_twitter_connect_session, :only => [:connect_twitter, :oauth_twitter]

  # render new.rhtml
  def new
    @user = User.new

    if params[:redirect_to]
      if !logged_in?
        store_location(params[:redirect_to])
      else
        redirect_to params[:redirect_to]
      end
    end

    ss_render_template(:try => 'index', :or => 'users/new',
                       :assigns => {:user => @user,
                                    :sso_site => @sso_selected_site})
  end

  def create
    logout_keeping_session!
    user = User.authenticate(@sso_selected_site, params[:email], params[:password])
    if user
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session
      self.current_user = user
      new_cookie_flag = (params[:remember_me] == "1")
      handle_remember_cookie! new_cookie_flag
      redirect_back_or_default('/')
      flash[:notice] = "Logged in successfully"
    else
      note_failed_signin
      @email = params[:email]
      @remember_me = params[:remember_me]
      @user = User.new

      render :action => 'new'
    end
  end

  def destroy
    if logged_in?
      fb_enabled = current_user.facebook_uid.to_i > 0

      if fb_enabled
        session[FacebookConnectHelper::FACEBOOK_CONNECT_SESSION_ID] = nil
        cookies.delete("#{FacebookConnectHelper::FACEBOOK_CONNECT_COOKIE_PREFIX}#{Facebooker.api_key}")
        logout_killing_session!
        store_location(params[:redirect_to])
        flash[:notice] = "You have been logged out."

        @redirect_path = session[:return_to] || '/'
        @redirect_path = '/' if @redirect_path.match(/logout/)
        session[:return_to] = nil
        session[:l] = I18n.locale
      else
        logout_killing_session!
        store_location(params[:redirect_to])
        flash[:notice] = "You have been logged out."
        session[:l] = I18n.locale
        redirect_back_or_default('/')
      end
    else
      redirect_back_or_default('/')
    end
  end

  def check

  end

  def session_user
    respond_to do |f|
      user_attributes = current_user.attributes
      user_attributes.stringify_keys!
      user_attributes.delete('salt')
      user_attributes.delete('password')
      user_attributes.delete('remember_token_expires_at')
      user_attributes.delete('crypted_password')
      user_attributes.delete('activation_code')
      user_attributes.delete('remember_token')
      f.json {render :json => user_attributes.to_json}
      f.php do
        text = "array("
        text << user_attributes.collect{|k, v| "'#{k}' => \"#{v}\""}.join(', ')
        text << ")"
        render :text => text
      end
    end
  end

  def connect_twitter
    request_token = @client.authentication_request_token(
        :oauth_callback => oauth_twitter_session_url)

    session[:request_token] = request_token.token
    session[:request_token_secret] = request_token.secret
    redirect_to request_token.authorize_url.gsub('authorize', 'authenticate')
  end

  def oauth_twitter
    if session[:token].nil? || session[:secret].nil?
      @oauth_verifier = params[:oauth_verifier]
      @access_token = @client.authorize(
          session[:request_token], session[:request_token_secret],
          :oauth_verifier => @oauth_verifier)

      if (@result = @client.authorized?)
        session[:token] = @access_token.token
        session[:secret] = @access_token.secret

        session[:request_token] = nil
        session[:request_token_secret] = nil

        flash[:notice] = "You've logged through your Twitter account."
      else
        flash[:notice] = "Failed to log in through your Twitter account."
      end
    end

    if (session[:token] && !logged_in?)
      self.current_user = User.find_or_create_with_twitter_account(@sso_selected_site, @client)
      redirect_back_or_default('/')
    else
      redirect_to root_url
    end
  end

  protected
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = "Couldn't log you in as '#{params[:email]}'"
    logger.warn "Failed login for '#{params[:email]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end
