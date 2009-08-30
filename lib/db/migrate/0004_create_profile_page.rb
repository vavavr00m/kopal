class CreateProfilePage < ActiveRecord::Migration

  def self.up
    create_table :profile_page do |t|
      t.string :page_name
      t.string :page_text
    end
    add_index :profile_page, :page_name, :unique => true
  end

  def self.down
    drop_table :profile_page
  end
end