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

  #FIXME: running <tt>rake kopal:first_time</tt> invokes this method twice.
  def perform_first_time_tasks
    puts "**** Welcome to Kopal ****"
    if Kopal::Profile.default_profile
      #TODO: More helpful message
      puts "Default profile is already present"
      return
    end
    #puts "Enter your preferred language. Available languages are - []. default is [en]"
    name = nil #"name" is already defined and returns "Kopal::Model"
    while name.blank?
      puts "Enter your full name"
      name = $stdin.gets.strip
    end
    default_profile = name.split(' ').first.to_s + "'s profile"
    puts "Enter name of profile. Leave blank for default. Default is #{default_profile.inspect}"
    profile = $stdin.gets.strip.presence || default_profile
    email = nil
    while email.blank?
      puts "Enter your email"
      email = $stdin.gets.strip
    end
    password = 'secret01' #use "highline" gem?
    create_default_profile_account_and_user! :full_name => name, :email => email, :password => password, :profile_name => profile
    puts "Your kopal profile has been created with following information"
    puts "Name: #{name}"
    puts "Profile name: #{profile}"
    puts "Email: #{email}"
    puts "Password: #{password}"
    puts "Your password has been set to #{password.inspect}. Please change it by visiting your profile."
  end
  
  #@return [Kopal::Profile] returns the "default" profile
  def create_default_profile_account_and_user! options
    options.to_options!.assert_valid_keys :full_name, :email, :password, :profile_name
    raise DefaultProfileExistsAlready if Kopal::Profile.default_profile
    #TODO: Any way to get all following done in one commit?
    profile = Kopal::Profile.create!(
      :identifier => Rails.application.config.kopal.default_profile_identifier,
      :name => options[:profile_name],
      :feed_data => {
        :real_name => options[:full_name]
      }
    )
    account = profile.accounts.create!(:superuser => true)
    user = account.build_user(
      :full_name => options[:full_name], 
      :emails => [Kopal::UserEmail.new :string => options[:email]],
      :password => options[:password]
    ).save!
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

