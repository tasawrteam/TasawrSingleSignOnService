class AddDefaultToSsoSites < ActiveRecord::Migration
  def self.up
    add_column :sso_sites, :default, :boolean, :default => false
  end

  def self.down
    remove_column :sso_sites, :default
  end
end
