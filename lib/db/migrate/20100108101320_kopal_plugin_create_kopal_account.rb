class KopalPluginCreateKopalAccount < ActiveRecord::Migration

  def self.kopal_account_table_name
    :"#{Kopal::KopalModel.name_prefix}kopal_account"
  end

  def self.up

    create_table kopal_account_table_name do |t|
      t.string :identifier_from_application
      t.timestamps
    end

    add_index kopal_account_table_name , :identifier_from_application, :unique => true
  end

  def self.down
    drop_table kopal_account_table_name
  end
end
