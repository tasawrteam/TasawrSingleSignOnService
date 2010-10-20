class SsoSite < ActiveRecord::Base
  
  @@sso_site_maps = {}
  serialize :content_map

  def self.match_host(host)
    if sso_site = @@sso_site_maps[host]
      return sso_site
    else
      SsoSite.all(:conditions => 'domain IS NOT NULL').each do |sso_site|
        hosts = sso_site.domain.split(/,/).collect(&:strip).compact
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
end
