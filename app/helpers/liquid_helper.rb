module LiquidHelper

end

class SsoLiquidTag < Liquid::Tag
  include SsoSitesHelper
  SIMPLE_SYNTAX = /^#{Liquid::QuotedFragment}+/
  NAMED_SYNTAX  = /^(#{Liquid::QuotedFragment})\s*\:\s*(.*)/

  def initialize(tag_name, markup, tokens)
    if !(markup || '').blank?
      case markup
        when NAMED_SYNTAX
          @variables = variables_from_string($2)
          @name = $1
        when SIMPLE_SYNTAX
          @variables = variables_from_string(markup)
          @name = "'#{@variables.to_s}'"
        else
          raise SyntaxError.new("Syntax Error in '#{tag_name}' - Valid syntax: #{tag_name} 'field key', 'default text'")
      end
    end
    super
  end

  private
    def variables_from_string(markup)
      markup.split(',').collect do |var|
    	  var =~ /\s*(#{Liquid::QuotedFragment})\s*/
    	  $1 ? $1 : nil
    	end.collect{|t| t.gsub("'", '')}.compact
    end

    def find_value_from_model(model, attribute)
      if model.respond_to?(attribute.to_sym)
        model.send(attribute.to_sym)
      else
        nil
      end
    end
end

class SsoLiquidBlockTag < Liquid::Block
  include SsoSitesHelper

  SIMPLE_SYNTAX = /^#{Liquid::QuotedFragment}+/
  NAMED_SYNTAX  = /^(#{Liquid::QuotedFragment})\s*\:\s*(.*)/

  def initialize(tag_name, markup, tokens)
    case markup
      when NAMED_SYNTAX
        @variables = variables_from_string($2)
        @name = $1
      when SIMPLE_SYNTAX
        @variables = variables_from_string(markup)
        @name = "'#{@variables.to_s}'"
      else
        raise SyntaxError.new("Syntax Error in 'content_field' - Valid syntax: content_field 'field key', 'default text'")
    end
    super
  end

  private
    def variables_from_string(markup)
      markup.split(',').collect do |var|
    	  var =~ /\s*(#{Liquid::QuotedFragment})\s*/
    	  $1 ? $1 : nil
    	end.collect{|t| t.gsub("'", '')}.compact
    end

end

module SsoSiteTags

  #
  # Retrieve value from the site related data container.
  # Example: content_field 'key', 'default message', ['true'|'false']
  # If the 3 argument is set to 'false' there won't be any html output
  # rather a variable "field_#{key}" will be assigned.
  #
  class Field < SsoLiquidTag

    def render(context)
      @sso_site = context['sso_site'] if @sso_site.nil?
      value = sso_site_field(@variables.first, @variables[1])

      if @variables.length > 2 && @variables[2].to_s.downcase == 'false'
        context.scopes.last["field_#{@variables.first}"] = value
        nil
      else
        value
      end
    end
  end

end

module RailsResourceTags
  class JSTag < SsoLiquidTag
    def render(context)
      html = ""
      @variables.each do |src|
        html << "<script type='text/javascript' src='/javascripts/#{src}.js'></script>"
      end
      html
    end
  end

  class CSSTag < SsoLiquidTag
    def render(context)
      html = ""
      @variables.each do |src|
        html << "<link rel='stylesheet' type='text/css' href='/stylesheets/#{src}#{!src.match(/\.css/i) ? '.css' : ''}'/>"
      end
      html
    end
  end

  class ImageTag < SsoLiquidTag
    def render(context)
      
    end
  end

  #
  # Implementation of rails form_for helper
  class FormTag < SsoLiquidTag

    def render(context)
      action_url = @variables.first
      action_url = action_url.match(/^@/) ? context[action_url.gsub('@', '')] : action_url
      form_id = @variables.length > 2 ? @variables[2] : action_url.gsub('/', '')

      %{<form action="#{action_url}" method="POST" id="#{form_id}">}
    end
  end

  class EndFormTag < SsoLiquidTag
    def render(context)
      "</form>"
    end
  end

  class FormAuthenticityTokenTag < SsoLiquidTag
    def render(context)
      "<input type='hidden' name='authenticity_token' value='#{context['form_authenticity_token']}'/>"
    end
  end

  class ErrorMessagesForTag < SsoLiquidTag
    extend ActionView::Helpers::ActiveRecordHelper

    def render(context)
      self.class.error_messages_for(@variables.first.to_sym)  
    end
  end

  class TextFieldTag < SsoLiquidTag
    def initialize(tag_name, markup, tokens)
      super
      @type = 'text'
    end

    def render(context)
      model = @variables.first
      attribute = @variables[1]
      value = @variables[2] || find_value_from_model(context[model], attribute)

      %{<input type='#{@type}' id='#{model}_#{attribute}' name='#{model}[#{attribute}]' value="#{value}"/>}
    end
  end

  class PasswordFieldTag < TextFieldTag
    def initialize(tag_name, markup, tokens)
      super
      @type = 'password'
    end
  end

  class RadioButtonTag < TextFieldTag
    def initialize(tag_name, markup, tokens)
      super
      @type = 'radio'
    end
  end

  class FieldLabelTag < SsoLiquidTag
    def render(context)
      model = @variables.first
      attribute = @variables[1]
      value = @variables[2]

      %{<label for='#{model}_#{attribute}'>#{value}</label>}
    end
  end
end

#
# Liquid Filters
#
module TextFilters
  class Text
    extend ActionView::Helpers::TextHelper

    def self.tag(a, b, c)
      "<#{a}>"  
    end
  end

  def simple_format(input)
    Text.simple_format(input)  
  end
end



# Register tags
Liquid::Template::register_tag('content_field', SsoSiteTags::Field)
Liquid::Template::register_tag('javascript_include_tag', RailsResourceTags::JSTag)
Liquid::Template::register_tag('stylesheet_link_tag', RailsResourceTags::CSSTag)
Liquid::Template::register_tag('image_tag', RailsResourceTags::ImageTag)
Liquid::Template::register_tag('form_tag', RailsResourceTags::FormTag)
Liquid::Template::register_tag('end_form_tag', RailsResourceTags::EndFormTag)
Liquid::Template::register_tag('text_field', RailsResourceTags::TextFieldTag)
Liquid::Template::register_tag('password_field', RailsResourceTags::PasswordFieldTag)
Liquid::Template::register_tag('field_label', RailsResourceTags::FieldLabelTag)
Liquid::Template::register_tag('radio_button', RailsResourceTags::RadioButtonTag)
Liquid::Template::register_tag('form_authenticity_token', RailsResourceTags::FormAuthenticityTokenTag)
Liquid::Template::register_tag('error_messages_for', RailsResourceTags::ErrorMessagesForTag)

# Register filters
Liquid::Template::register_filter(TextFilters)
