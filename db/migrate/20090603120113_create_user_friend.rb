class CreateUserFriend < ActiveRecord::Migration
  def self.up
    create_table :user_friend do |t|
      t.string :kopal_identity, :friendship_state, :null => false
      t.string :gender, :length => 1
      t.string :country_living_code, :length => 2
      t.string :name, :description, :city_name, :friend_group, :image_path
      t.timestamps
    end
    add_index :user_friend, :kopal_identity, :unique => true
  end

  def self.down
    drop_table :user_friend
  end
end
