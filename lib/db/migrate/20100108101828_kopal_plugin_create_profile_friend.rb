class KopalPluginCreateProfileFriend < ActiveRecord::Migration

  def self.profile_friend_table_name
    :"#{Kopal::KopalModel.name_prefix}profile_friend"
  end

  def self.up
    create_table profile_friend_table_name do |t|
      t.references :kopal_account, :null => false
      t.string :friend_kopal_identity, :friendship_state, :friendship_key, :null => false
      t.text :friend_kopal_feed, :friend_public_key, :null => false
      t.string :friend_group
      t.timestamps
    end
    add_index profile_friend_table_name, [:kopal_account_id, :friend_kopal_identity], :unique => true
  end

  def self.down
    drop_table profile_friend_table_name
  end
end
