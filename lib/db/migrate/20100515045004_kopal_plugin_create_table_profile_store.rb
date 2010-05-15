class KopalPluginCreateTableProfileStore < ActiveRecord::Migration

  def self.profile_store_table_name
    :"#{Kopal::Model.name_prefix}profile_store"
  end

  def self.up
    create_table profile_store_table_name do |t|
      t.string :widget_key, :null => false
      t.string :record_name, :null => false
      t.text :record_text
      t.integer :scope, :null => false, :default => 0
    end
    add_index profile_store_table_name, :widget_key
    add_index profile_store_table_name, [:widget_key, :record_name], :unique => true
  end

  def self.down
    drop_table profile_store_table_name
  end
end