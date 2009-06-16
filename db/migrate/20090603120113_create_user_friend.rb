class CreateUserFriend < ActiveRecord::Migration
  def self.up
    create_table :user_friend do |t|
      t.string :kopal_identity, :friendship_state, :null => false
      t.text :kopal_feed, :null => false
      t.string :friend_group
      t.timestamps
    end
    add_index :user_friend, :kopal_identity, :unique => true
  end

  def self.down
    drop_table :user_friend
  end
end
