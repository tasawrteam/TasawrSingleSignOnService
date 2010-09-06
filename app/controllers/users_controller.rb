class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  layout 'basic'
  

  # render new.rhtml
  def new
    @user = User.new
    render :action => '../sessions/new'
  end
 
  def create
    logout_keeping_session!
    @user = User.new(params[:user])
    success = @user && @user.save
    if success && @user.errors.empty?
      redirect_to root_url
      flash[:notice] = "Thanks for signing up!  We're sending you an email with your activation code."
    else
      flash[:error]  = "We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above)."
      render :action => '../sessions/new'
    end
  end

  def activate
    logout_keeping_session!
    user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    case
    when (!params[:activation_code].blank?) && user && !user.active?
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
  end

  def update
    @user = current_user.reload
    old_password = params[:old_password]
    user_params = params[:user]
    user_params.delete(:id)
    user_params.delete(:birthday)
    user_params.delete(:email)
    user_params.delete(:mobile)
    user_params.delete(:gender)

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
end
