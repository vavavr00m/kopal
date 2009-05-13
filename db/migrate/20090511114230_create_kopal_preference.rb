class CreateKopalPreference < ActiveRecord::Migration

  def self.up
    create_table :kopal_preference do |t|
      t.string :preference_name
      t.text :preference_text
      t.timestamps
    end
    add_index :kopal_preference, :preference_name, :unique => true
  end
 
  def self.down
  drop_table :kopal_preference
  end
end

