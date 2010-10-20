module SsoSitesHelper

  def detect_sso_site
    @sso_selected_site = SsoSite.match_host(request.host)
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
end
