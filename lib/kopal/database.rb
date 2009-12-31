#Define databases for kopal in RAILS_ROOT/config/kopal.database.yml,
#if the file is not found, a SQLite3 databse at RAILS_ROOT/db/kopal.RAILS_ENV.sqlite3 is assumed.
#If the adapter is <tt>self</tt>, Kopal will use the default database of application with default prefix <tt>kopal_</tt>
#Example -
#<tt>
#development:
#  adapter: self
#  prefix: kp_
#production:
#  adapter: sqlite3
#  database: db/kopal.production.sqlite3
#  prefix: kp_ #allowed here too.
#</tt>
#
#At present only SQLite3 is supported.
#
#Since !same connection/request is possible, there is no use to put in kopal-lib.
#integrate to +Kopal::KopalModel+
class Kopal::Database

  def initialize database_path = nil
    @database = database_path || 
      File.join(RAILS_ROOT, 'db', 'kopal.' + RAILS_ENV + '.sqlite3')
  end
  
  #At present only SQLite3 is supported with default database path.
  def connection
   @connection = {
    :adapter => 'sqlite3',
    :database => @database
   }
  end
  
  def self?
    false #Application database is not yet supported.
  end
  
  def name_prefix
    @@name_prefix = self?() ? 'kopal_' : ''
  end

  def migration_needed?
    last_migrated_number != latest_migration_number
  end

  def migrate!
    establish_connection
    ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
    ActiveRecord::Migrator.migrate("#{KOPAL_ROOT}/lib/db/migrate/", ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
    if self?()
      Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
    end
    revert_to_previous_connection
  end

  def delete_and_migrate!
    File.delete(@database)
    migrate!
  end

  def last_migrated_number
    establish_connection
    v = ActiveRecord::Migrator.current_version
    revert_to_previous_connection
    v
  end

  def latest_migration_number
    Dir[Kopal.root.join('lib', 'db', 'migrate', '*.rb')].map {|f|
      File.basename(f).to_i
    }.max || 0
  end
  
  #Connect to Kopal databse in present environment
  def establish_connection
    @previous_connection = ActiveRecord::Base.connection
    ActiveRecord::Base.establish_connection connection
  end

  #This is ugly
  def revert_to_previous_connection
    #Need to pass connection hash instead of connection object.
    #ActiveRecord::Base.establish_connection @previous_connection
  end

  def perform_first_time_tasks
    if Kopal[:account_password_hash].nil?
      Kopal::KopalPreference.save_password(Kopal::KopalPreference::DEFAULT_PASSWORD)
    end
  end

  #Returns an XML string representing the database. Excludes environment specific
  #fields example - password, openid stores.
  def backup
    raise NotImplementedError
  end

  def restore
    Rake::Task['kopal:clear_database'].invoke
  end

end
