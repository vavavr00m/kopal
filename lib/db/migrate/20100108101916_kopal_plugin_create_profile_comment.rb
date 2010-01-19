class KopalPluginCreateProfileComment < ActiveRecord::Migration

  def self.profile_comment_table_name
    :"#{Kopal::KopalModel.name_prefix}profile_comment"
  end

  def self.up
    create_table profile_comment_table_name do |t|
      t.references :kopal_account, :null => false
      t.string :name, :name => 255
      t.string :email
      t.string :website_address, :length => 255
      t.integer :is_kopal_identity
      t.text :comment_text, :null => false
      t.timestamps
    end
    add_index profile_comment_table_name, :kopal_account_id
  end

  def self.down
    drop_table profile_comment_table_name
  end
end
