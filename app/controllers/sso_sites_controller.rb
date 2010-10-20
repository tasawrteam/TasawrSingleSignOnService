class SsoSitesController < ApplicationController
  
  include AuthenticatedSystem
  before_filter :login_required
  layout 'basic'
  
  def index
    @sso_sites = SsoSite.all
  end

  def new
    @sso_site = SsoSite.new
  end

  def create
    @sso_site = SsoSite.new(params[:sso_site])
    if @sso_site.save
      flash[:success] = 'New site added!'
      redirect_to sso_sites_url
    else
      flash[:notice] = 'Failed to add new site!'
      render :action => :new
    end
  end

  def destroy
    @sso_site = SsoSite.find(params[:id])
    if @sso_site.destroy
      flash[:success] = 'Removed sso site!'
    else
      flash[:notice] = 'Failed to remove sso site!'
    end

    redirect_to sso_sites_url
  end

  def edit
    @sso_site = SsoSite.find(params[:id])
    render :action => :new
  end

  def update
    @sso_site = SsoSite.find(params[:id])
    if @sso_site.update_attributes(params[:sso_site])
      flash[:success] = 'Successfully saved!'
      redirect_to edit_sso_site_path(@sso_site)
    else
      flash[:notice] = 'Failed to save!'
      render :action => :new
    end
  end
end
