class SsoSite < ActiveRecord::Base

  named_scope :default, :conditions => {:default => true}
  has_many :users

  liquid_methods :domain, :title, :logo_url, :theme_css, :created_at,
                 :content_map, :template_suit
  
  @@sso_site_maps = {}
  serialize :content_map

  @@active_host = {}
  @@parsed_templates = {}

  def self.active_host(token)
    host = @@active_host[token]
    @@active_host.delete(token)
    host
  end

  def self.add_active_host(host)
    key = "#{rand * Time.now.to_i}"
    @@active_host[key] = host
    key
  end

  def self.match_host(host)
    if sso_site = @@sso_site_maps[host]
      return sso_site
    else
      SsoSite.all(:conditions => 'domain IS NOT NULL').each do |sso_site|
        hosts = sso_site.domain.split(/,/).collect(&:strip).compact
        puts hosts.inspect
        hosts.each do |pt_host|
          if pt_host == host
            @@sso_site_maps[host] = sso_site
            return sso_site
          elsif pt_host.match(/#{host}$/)
            @@sso_site_maps[host] = sso_site
            return sso_site
          end
        end
      end

      return nil
    end
  end

  def render_file(file, assignments, options = {})
    assignments.stringify_keys!
    template_file = File.join(template_suit, "#{file}.liquid")

    if File.exist?(template_file)
      parsed_template = @@parsed_templates[template_file] ||= Liquid::Template.parse(File.read(template_file))
      parsed_template.render(assignments, options)
    else
      nil
    end
  end
end
