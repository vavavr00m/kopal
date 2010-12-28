class KopalPluginCreateKopalPreference < ActiveRecord::Migration

  def self.kopal_preference_table_name
    :"#{Kopal::KopalModel.name_prefix}kopal_preference"
  end

  def self.up
    create_table kopal_preference_table_name do |t|
      t.references :kopal_account, :null => false
      t.string :preference_name, :null => false
      t.text :preference_text
      t.timestamps
    end
    add_index kopal_preference_table_name, [:kopal_account_id, :preference_name], :unique => true,
      :name => "index_#{kopal_preference_table_name}_on_kaid_and_pn" #Avoid PostgreSQL NAMEDATALEN-1 (63).
  end
 
  def self.down
    drop_table kopal_preference_table_name
  end
end

