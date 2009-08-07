class CreateProfileComment < ActiveRecord::Migration
  def self.up
    create_table :profile_comment do |t|
      t.string :name, :name => 255
      t.string :email
      t.string :website_address, :length => 255
      t.integer :is_kopal_identity
      t.text :comment_text, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :profile_comment
  end
end
