#TODO: Allow Kopal's Mongoid configuration to differ from applications', even
#allow a different database. Bascially, if application is not using Mongoid,
#then do not force user to created config/mongoid.yml and if application is
#using Mongoid, then allow Kopal to have different configurations from 
#config/mongoid.yml and if possible even a different database.
class Kopal::Model
  class DefaultProfileExistsAlready < Kopal::Exception::ApplicationError; end;
  
  include Kopal::KopalHelper
class << self

  def inherited subclass
#    subclass.send :include, Mongoid::Document
    subclass.instance_eval do
      include Mongoid::Document
      include Mongoid::Timestamps
      subclass.collection_name = "#{collection_prefix}#{subclass.to_s.demodulize.underscore}"
    end
  end

  def collection_prefix
    Rails.application.config.kopal.collection_prefix
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
    []
  end

  def all_migration_numbers_of_application
    []
  end

  #belongs to Kopal::KopalAccount
  def perform_first_time_tasks
    #Options to choose language.
    #
    #Create default user account.
    Kopal::KopalAccount.create_default_profile!
  end
  
  #@return [Kopal::Profile] returns the "default" profile
  def create_default_profile_account_and_user!
    raise DefaultProfileExistsAlready if default_profile
    profile = Kopal::Profile.create!(
      :identifier => Rails.application.config.kopal.default_profile_idenfier,
      :feed_data => {
        :real_name => "Default profile"
      }
    )
    account = profile.accounts.create!(:superuser => true)
    user = account.build_user(:full_name => "Default user").save!
    account.profile.reload
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

