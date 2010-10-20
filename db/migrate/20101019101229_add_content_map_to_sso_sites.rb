class AddContentMapToSsoSites < ActiveRecord::Migration
  def self.up
    add_column :sso_sites, :content_map, :text
  end

  def self.down
    remove_column :sso_sites, :content_map
  end
end
