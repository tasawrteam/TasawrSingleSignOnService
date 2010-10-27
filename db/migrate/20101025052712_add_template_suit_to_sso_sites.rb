class AddTemplateSuitToSsoSites < ActiveRecord::Migration
  def self.up
    add_column :sso_sites, :template_suit, :string
  end

  def self.down
    remove_column :sso_sites, :template_suit
  end
end
