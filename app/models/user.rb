require 'digest/sha1'

class User < ActiveRecord::Base

  belongs_to :sso_site

  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken

  validates_format_of :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of :name,     :maximum => 100

  validates_presence_of :email
  validates_length_of :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of :email, :scope => :sso_site_id
  validates_format_of :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message
  validates_acceptance_of :terms_and_conditions, :on => :create

  before_create :make_activation_code

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :email, :name, :birthday, :gender, :mobile, :password,
                  :password_confirmation, :reset_password_code, :host_token,
                  :terms_and_conditions

  liquid_methods :name, :email, :birthday, :gender, :mobile, :created_at,
                 :facebook_uid, :twitter_uid, :sso_site, :errors

  def host_token
    @host_token
  end

  def host_token=(token)
    @host_token = token
  end

  def old_password_matches?(old_password)
    encrypt(old_password) == self.crypted_password
  end

  # Activates the user in the database.
  def activate!
    @activated = true
    self.activated_at = Time.now.utc
    self.activation_code = nil
    save(false)
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end

  def active?
    # the existence of an activation code means they have not activated yet
    activation_code.nil?
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(sso_site, email, password)
    return nil if email.blank? || password.blank?
    u = self.find_by_email_and_sso_site_id(email, sso_site)
    u && u.authenticated?(password) ? u : nil
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  def self.find_or_create_with_twitter_account(sso_site, client)
    twitter_user = client.info
    twitter_uid = twitter_user['id']

    user = User.find_by_sso_site_id_and_twitter_uid(sso_site.id, twitter_uid)
    return user if user

    user = User.new(
        :name => twitter_user['name'],
        :email => find_or_build_unique_fake_email('fake'),
        :activated_at => Time.now,
        :twitter_uid => twitter_uid.to_i,
        :sso_site_id => sso_site.id,
        :twitter_connect_enabled => true,
        :terms_and_conditions => true)
    user.save(false)
    return user
  end

  def self.register_by_facebook_account(sso_site, fb_session, fb_uid)
    api = FacebookGraphApi.new(fb_session.auth_token, fb_uid)
    user_attributes = api.find_user(fb_uid)
    email = user_attributes['email'] || 'FAKE'
    name = user_attributes['name'] || ''

    if !email.blank? && !name.blank?
      existing_user = User.find_by_sso_site_id_and_email(sso_site.id, email)
      existing_user = User.find_by_sso_site_id_and_facebook_uid(sso_site.id, fb_uid) if existing_user.nil?

      if existing_user
        existing_user.facebook_uid = fb_uid
        existing_user.facebook_sid = fb_session.auth_token
        existing_user.facebook_connect_enabled = true
        existing_user.save(false)

      else
        attributes = {
            :name => name,
            :email => find_or_build_unique_fake_email(email),
            :facebook_uid => fb_uid,
            :facebook_sid => fb_session.session_key,
            :activated_at => Time.now,
            :sso_site_id => sso_site.id,
            :facebook_connect_enabled => true,
            :terms_and_conditions => true
        }

        user = User.new(attributes)
        user.save(false)
      end
    else
      # Do something else let's log him out from facebook
      raise 'Durrr! you are one of those unlucky person for whom we haven\'t fixed this bug!
            please let me know that i told you this crap!' + " data - #{user_attributes.inspect}"
    end
  end

  def self.update_facebook_session(sso_site, fb_uid, fb_session)
    existing_user = User.find_by_sso_site_id_and_facebook_uid(sso_site.id, fb_uid)
    existing_user.facebook_sid = fb_session.auth_token
    existing_user.save(false)
  end

  private
    def self.find_or_build_unique_user_name (name)
      name = CGI.escape(name.parameterize.to_s)
      if self.unique?(:login, name)
        name
      else
        "#{name}-#{Time.now.to_i.to_s[6..10].to_i}"
      end
    end

    def self.find_or_build_unique_fake_email(email)
      if email.downcase != 'fake' && self.unique?(:email, email)
        email
      elsif email.downcase == 'fake'
        "#{email}@#{Time.now.to_i.to_s[6..10].to_i}.com"
      else
        email
      end
    end

    def self.unique?(field, value)
      !User.send("find_by_#{field}", value)
    end

  protected

    def make_activation_code
      self.activation_code = self.class.make_token
    end


end
