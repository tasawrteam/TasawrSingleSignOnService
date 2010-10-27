class AddSsoSiteIdToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :sso_site_id, :integer
  end

  def self.down
    remove_column :users, :sso_site_id
  end
end
