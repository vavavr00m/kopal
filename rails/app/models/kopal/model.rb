class Kopal::Model < ActiveRecord::Base
  #Best thing would be to have migrations in schema_migrations as "kopal_1234", but Rails only supports Integer migrations.
  class Migrator < ActiveRecord::Migrator
    def schema_migrations_table_name
      "#{name_prefix}_kopal_schema_migrations"
    end
  end
  
  self.abstract_class = true
  include Kopal::KopalHelper
class << self

  def name_prefix
    configurations[RAILS_ENV]['kopal_prefix'] ||
      'kopal_'
  end

  #Checks if migrations are needed, only for schema belonging to Kopal.
  def migration_needed?
    last_migrated_number != latest_migration_number
  end

  def migrate!
    #Checks if any migration has same version number of any application migration.
    #What about conflicts with another plugin's migrations?
    duplicates = all_migration_numbers_of_application & all_migration_numbers
    if(duplicates.size > 0)
      raise "ERROR: Duplicate migration numbers - #{duplicates.to_sentence :last_word_connector => ' and'}"
    end
    ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
    Migrator.migrate(Kopal.path.migrate.to_s)
    Rake::Task["db:schema:dump"].invoke if schema_format == :ruby
  end

  #Find the last migration number for Kopal.
  def last_migrated_number
    (ActiveRecord::Migrator.get_all_versions & all_migration_numbers).max.to_i #nil to zero
  end

  def latest_migration_number
    all_migration_numbers.max || 0
  end

  def all_migration_numbers
    Dir[Kopal.path.rails.migrate.join('*.rb')].map {|f|
      File.basename(f).to_i
    }
  end

  def all_migration_numbers_of_application
    Dir[Rails.root.join('db', 'migrate', '*.rb')].map {|f|
      File.basename(f).to_i
    }
  end

  #belongs to Kopal::KopalAccount
  def perform_first_time_tasks
    #Options to choose language.
    #
    #Create default user account.
    Kopal::KopalAccount.create_default_profile_account!
  end

  #Returns an XML string representing the database. Excludes environment specific
  #fields example - password, openid stores.
  def backup
    raise NotImplementedError
  end

  def restore
    raise NotImplementedError
    Rake::Task['kopal:clear_database'].invoke
  end

end
end

