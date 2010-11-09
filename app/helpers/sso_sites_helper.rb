module SsoSitesHelper

  def detect_sso_site
    @sso_selected_site = SsoSite.match_host(request.host)
    if @sso_selected_site.nil?
      @sso_selected_site = SsoSite.default.first
    end

    @url_prefix = request.env['SERVER_PROTOCOL'].match(/HTTP/i) ? 'http://' : 'https://'
    @host_token = SsoSite.add_active_host(request.host)
    @template_suit = @sso_selected_site.template_suit
  end

  def sso_site_field(field, default)
    if (@sso_site || @sso_selected_site) && field == :site_title
      return (@sso_site || @sso_selected_site).title
    end

    if (@sso_site || @sso_selected_site) && (value = ((@sso_site || @sso_selected_site).content_map || {})[field])
      value
    else
      default
    end
  end

  def ss_form_field(field_type, field_key, options = {})
    value = sso_site_field(field_key, nil)
    html = ""

    case field_type
      when :text
        html = "<input id='sso_site_content_map_#{field_key}' type='text' name='sso_site[content_map][#{field_key}]'"
        html << %{ #{options.collect{|k, v| %{#{k}="#{v}"}}.join(' ')}}
        html << " value='#{value.gsub(/'/, '"')}'" if value
        html << "/>"

      when :text_area
        html = "<textarea id='sso_site_content_map_#{field_key}' name='sso_site[content_map][#{field_key}]'"
        html << %{ #{options.collect{|k, v| %{#{k}="#{v}"}}.join(' ')}}
        html << ">"
        html << value if value
        html << "</textarea>"
    end

    html
  end

  def ss_form_label(field_key, label)
    "<label for='sso_site_content_map_#{field_key}'>#{label}</label>"
  end

  #
  # Example Usages :try => 'index', :or => 'users/new', :assigns => {:user => @user}
  #
  def ss_render_template(options)
    template_file = options[:try]
    default_template = options[:or]
    assignments = options[:assigns] || {}
    assign_required_variables(assignments)

    raise ':try and :or options are required' if template_file.nil? || default_template.nil?

    if @template_suit && !@template_suit.blank? && File.exist?(File.join(@template_suit, "#{template_file}.liquid"))
      render_with_liquid(template_file, assignments)
    else
      render :template => default_template
    end
  end

  private
    def render_with_liquid(template_file, assignments)
      # Configure liquid
      Liquid::Template.file_system = Liquid::LocalFileSystem.new(@template_suit)

      # Prepare response header
      response.headers["Content-Type"] ||= 'text/html; charset=utf-8'

      # Render template content
      template_content = @sso_selected_site.render_file(
          template_file, assignments, :filters => [SsoSitesHelper])

      # Render layout if presents
      layout_content = @sso_selected_site.render_file(
          'layout', assignments.merge({:content_for_layout => template_content}))
      if layout_content
        render :text => layout_content
      else
        render :text => template_content
      end
    end

    def assign_required_variables(assignments)
      assignments[:site_path] = "#{@url_prefix}#{request.host}"
      assignments[:sso_site] = @sso_selected_site
      assignments[:logged_in?] = logged_in?
      assignments[:current_user] = current_user
      flash.each do |k, v|
        assignments['flash_' + k.to_s] = v
      end

      assignments[:session_path] = session_path
      assignments[:session_url] = session_url

      assignments[:connect_twitter_session_path] = connect_twitter_session_path
      assignments[:connect_twitter_session_url] = connect_twitter_session_url

      assignments[:forgot_password_path] = forgot_password_path
      assignments[:forgot_password_url] = forgot_password_url

      assignments[:login_sub_view] = @login_sub_view
      assignments[:form_authenticity_token] = form_authenticity_token
      assignments[:user] = @user

      assignments[:users_path] = users_path
      assignments[:users_url] = users_url

      assignments[:root_url] = root_url
      assignments[:root_path] = root_path

      assignments[:facebooker_api_key] = Facebooker.api_key

      if logged_in?
        assignments[:edit_user_path] = edit_user_path(current_user.id)
        assignments[:edit_user_url] = edit_user_url(current_user.id)

        assignments[:user_path] = user_path(current_user.id)
        assignments[:user_url] = user_url(current_user.id)

        assignments[:logout_url] = logout_url
        assignments[:logout_path] = logout_path

        if current_user.admin?
          assignments[:sso_sites_url] = sso_sites_url
          assignments[:sso_sites_path] = sso_sites_path
        end
      end
    end
end
