module FacebookConnectHelper

  FACEBOOK_CONNECT_COOKIE_PREFIX = "fbs_"
  FACEBOOK_CONNECT_SESSION_ID = :fb_connect_user

  def check_facebook_connect_session
    if !fb_connect_session # not exists
      # Try to load facebook connect cookies
      # Create new facebook session and store on session
      fb_session = build_fb_session

      # If cookies are found
      if fb_session && fb_session.user

        # Create new facebook session and store on session
        fb_uid = fb_session.user.uid

        # Ensure associated user is already in database
        # otherwise create new user and assign on session

        if !User.exists?(:facebook_uid => fb_uid)
          User.register_by_facebook_account(@sso_selected_site, fb_session, fb_uid)
        else
          User.update_facebook_session(@sso_selected_site, fb_uid, fb_session)
        end

        self.current_user = User.find_by_sso_site_id_and_facebook_uid(@sso_selected_site.id, fb_uid)
        create_fb_connect_session(fb_session)
        flash[:notice] = 'You are logged in through your facebook account'
      end
    end

    if logged_in? && (params[:redirect_to] || session[:return_to])
      redirect_back_or_default params[:redirect_to]
      return false
    end
  end

  def facebook_config
    FACEBOOK_CONNECT[Rails.env.to_sym] || FACEBOOK_CONNECT[:else]
  end

  def twitter_config
    TWITTER_CONNECT[Rails.env.to_sym] || TWITTER_CONNECT[:else]
  end

  def facebook_secret
    facebook_config[:secret]
  end

  def facebook_app_id
    facebook_config[:appid]
  end

  def facebook_api_key
    facebook_config[:apikey]
  end

  def twitter_consumer_key
    twitter_config[:consumer_key]
  end

  def twitter_consumer_secret
    twitter_config[:consumer_secret]
  end

  def check_twitter_connect_session
    @client = TwitterOAuth::Client.new(
        :consumer_key => twitter_consumer_key,
        :consumer_secret => twitter_consumer_secret,
        :token => session[:token],
        :secret => session[:secret]
    )
  end

  private

    def fb_connect_session
      session[FACEBOOK_CONNECT_SESSION_ID]
    end

    def build_fb_session
      fb_cookie = cookies["#{FACEBOOK_CONNECT_COOKIE_PREFIX}#{Facebooker.api_key}"]
      parsed = {}

      if fb_cookie && !fb_cookie.blank?
        parsed = parse_fb_cookie(fb_cookie)

      elsif params[:fskey] && params[:fuid]
        parsed = {
            'session_key' => params[:fskey],
            'uid' => params[:fuid],
            'expires' => params[:fexpires],
            'secret' => params[:fsecret],
            'access_token' => params[:fat]
            }
      end

      if parsed && !parsed.empty?
        @facebook_session = new_facebook_session
        @facebook_session.secure_with!(
            parsed['session_key'],
            parsed['uid'],
            parsed['expires'],
            parsed['secret'])
        @facebook_session.auth_token = parsed['access_token']
        @facebook_session
      else
        nil
      end
    end

    def create_fb_connect_session(fb_session)
      session[FACEBOOK_CONNECT_SESSION_ID] = fb_session
    end

    def parse_fb_cookie(fb_cookie)
      map = {}
      fb_cookie = fb_cookie.gsub(/"/, '')
      fb_cookie.split('&').collect do |part|
        parts = part.split('=');
        map[parts.first] = parts.last
      end
      map['expires'] = Time.at(map['expires'].to_i)
      map
    end
end
