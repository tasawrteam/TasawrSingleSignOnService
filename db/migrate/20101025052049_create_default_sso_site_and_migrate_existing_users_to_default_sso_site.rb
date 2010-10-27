class CreateDefaultSsoSiteAndMigrateExistingUsersToDefaultSsoSite < ActiveRecord::Migration
  def self.up
    site = SsoSite.create(
        :domain => 'connect.hasansmac.com, connect.tasawr.info, connect.tasawr.net',
        :title => 'Tasawr Single Sign-On platform',
        :content_map => {
            :title => 'Welcome to Tasawr. Imagine.',
            :message => 'Tasawr is a community portal catering to internet users throughout the
Middle East. Register now to be part of this vibrant community.',
            :footer => '© 2010 Tasawr Interactive. All Rights Reserved.'},
        :default => true)

    if !site.id.nil?
      User.all.each do |user|
        user.update_attribute(:sso_site_id, site.id)
      end
    end
  end

  def self.down
  end
end
