class KopalPluginCreateTablePageWidget < ActiveRecord::Migration

  def self.page_widget_table_name
    :"#{Kopal::KopalModel.name_prefix}page_widget"
  end

  def self.up
    create_table page_widget_table_name do |t|
      t.references :page, :null => false
      t.string :widget_uri, :null => false
      t.string :widget_key, :null => false
      t.integer :position, :null => false, :default => 0
    end
    add_index page_widget_table_name, :page_id
    add_index page_widget_table_name, :widget_key, :unique => true
  end

  def self.down
    drop_table page_widget_table_name
  end
end