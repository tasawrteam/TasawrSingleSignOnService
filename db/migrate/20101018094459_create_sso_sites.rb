class CreateSsoSites < ActiveRecord::Migration
  def self.up
    create_table :sso_sites do |t|
      t.string :domain
      t.string :title
      t.string :logo_url
      t.text :theme_css

      t.timestamps
    end
  end

  def self.down
    drop_table :sso_sites
  end
end
