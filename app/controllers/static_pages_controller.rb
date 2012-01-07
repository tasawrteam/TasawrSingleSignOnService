class StaticPagesController < ApplicationController

  def serve
    page = File.join(RAILS_ROOT, 'public', 'static', "#{params[:name]}_#{I18n.locale.to_s.downcase}.erb")
    @defined_site_title = params[:name]
    
    if File.exist?(page)
      if params[:debug].nil?
        render :template => page, :layout => 'advanced'
      else
        render :text => File.read(page), :layout => 'advanced'
      end
    else
      flash[:notice] = 'No such page found!'
      redirect_to root_url
    end
  end
end
