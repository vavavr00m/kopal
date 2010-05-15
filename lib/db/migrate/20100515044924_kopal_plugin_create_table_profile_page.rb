class KopalPluginCreateTableProfilePage < ActiveRecord::Migration

  def self.profile_page_table_name
    :"#{Kopal::KopalModel.name_prefix}profile_page"
  end

  def self.up
    create_table profile_page_table_name do |t|
      t.references :kopal_account, :null => false
      t.string :page_name, :null => false
      t.string :visibility, :default => 'public', :null => false #'public', 'private', 'friend'
    end
    add_index profile_page_table_name, [:kopal_account_id, :page_name], :unique => true
  end

  def self.down
    drop_table profile_page_table_name
  end
end
