class AddFacebookUidAndFacebookSidToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :facebook_uid, :integer
    add_column :users, :facebook_sid, :integer
    add_column :users, :facebook_connect_enabled, :boolean, :default => true

    add_index :users, [:facebook_uid]
  end

  def self.down
    remove_column :users, :facebook_uid
    remove_column :users, :facebook_sid
    remove_column :users, :facebook_connect_enabled
  end
end
