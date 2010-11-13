class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  layout 'basic'

  before_filter :login_required, :only => [:edit, :update]

  # render new.rhtml
  def new
    @user = User.new
  end
 
  def create
    logout_keeping_session!
    @user = User.new(params[:user])
    @user.sso_site_id = @sso_selected_site.id
    @user.host_token = @host_token
    success = @user && @user.save
    if success && @user.errors.empty?
      redirect_to root_url
      flash[:notice] = "Thanks for signing up!  We're sending you an email with your activation code."
    else
      flash[:error]  = "We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above)."
      render :action => :new
    end
  end

  def activate
    logout_keeping_session!
    user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    case
      when (!params[:activation_code].blank?) && user && !user.active?
      user.host_token = @host_token
      user.activate!
      flash[:notice] = "Signup complete! Please sign in to continue."
      redirect_to root_url
    when params[:activation_code].blank?
      flash[:error] = "The activation code was missing.  Please follow the URL from your email."
      redirect_back_or_default('/')
    else 
      flash[:error]  = "We couldn't find a user with that activation code -- check your email? Or maybe you've already activated -- try signing in."
      redirect_back_or_default('/')
    end
  end

  def edit
    @user = current_user.reload
    store_location(params[:redirect_to])

    ss_render_template(:try => 'edit_user', :or => 'users/edit',
                       :assigns => {:user => @user,
                                    :sso_site => @sso_selected_site})
  end

  def update
    @user = current_user.reload
    @user.host_token = @host_token
    
    old_password = params[:old_password]
    user_params = params[:user]
    user_params.delete(:id)
    user_params.delete(:birthday)
    user_params.delete(:email)
    user_params.delete(:mobile)
    user_params.delete(:gender)
    user_params.delete(:sso_site_id)

    if @user.old_password_matches?(old_password)
      if !user_params[:password].blank? && !user_params[:password_confirmation].blank? &&
          user_params[:password] == user_params[:password_confirmation]
        @user.update_attributes(user_params)
        flash[:success] = 'Your password has been updated!'
        redirect_back_or_default('/')
      else
        flash[:notice] = "Perhaps your entered password doesn't match or you left some fields empty."
        redirect_to :back
      end
    else
      flash[:notice] = 'Old password doesn\'t match!'
      redirect_to :back
    end

  end

  def forgot_password
    @login_sub_view = :forgot_password
    @user = User.new
    render :template => 'sessions/new'
  end

  def reset_password
    @email = params[:email]
    if @email
      user = User.find_by_sso_site_id_and_email(@sso_selected_site.id, @email)
      if user
        user.host_token = @host_token
        reset_code = "#{Time.now.to_i}#{rand(1000)}"
        if user.update_attribute(:reset_password_code, reset_code)
          flash[:success] = 'Please check your email address, we have just sent password reset link.'
          redirect_to root_url
          return
        else
          flash[:notice] = 'Failed to reset your password!'
        end
        
      else
        flash[:notice] = 'Email address doesn\'t exist.'
      end
    else
      flash[:notice] = 'Please enter your email address.'
    end

    redirect_to :back
  end

  def change_password
    code = params[:code] || ''
    if code.empty?
      flash[:notice] = 'No reset password token was found!'
    else
      @user = User.find_by_sso_site_id_and_reset_password_code(@sso_selected_site.id, code)
      if @user
        flash[:success] = 'Set your new password!'
        session[:approved_token] = code
        session[:approved_user_id] = @user.id
        return
      else
        flash[:notice] = 'No such user found!'
        redirect_to root_url
        return
      end
    end

    redirect_to :back
  end

  def save_password
    @user = User.find(session[:approved_user_id].to_i)
    map = params[:user]
    map[:reset_password_code] = nil
    
    if @user.update_attributes(map)
      session[:approved_token] = nil
      session[:approved_user_id] = nil
      flash[:success] = 'We have stored your new password!'
      redirect_to root_url
    else
      flash[:notice] = 'Failed to store your password!'
      redirect_to change_password_url(session[:approved_token])
    end
  end
end
