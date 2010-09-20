class AddTwitterUidAndTwitterConnectEnabledToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :twitter_uid, :bigint
    add_column :users, :twitter_connect_enabled, :boolean
  end

  def self.down
    remove_column :users, :twitter_connect_enabled
    remove_column :users, :twitter_uid
  end
end
