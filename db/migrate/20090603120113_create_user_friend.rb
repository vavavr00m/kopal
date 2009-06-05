class CreateUserFriend < ActiveRecord::Migration
  def self.up
    create_table :user_friend do |t|
      t.string :kopal_identity, :name, :friendship_state, :null => false
      t.string :gender, :length => 1
      t.string :description, :country_living_code, :city, :friend_group
      t.timestamps
    end
    add_index :user_friend, :kopal_identity, :unique => true
  end

  def self.down
    drop_table :user_friend
  end
end
