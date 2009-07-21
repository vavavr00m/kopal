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
class Kopal::Database

class << self
  
  #At present only SQLite3 is supported with default database path.
  def connection
   @connection = {
    :adapter => 'sqlite3',
    :database => RAILS_ROOT + '/db/kopal.' + RAILS_ENV + '.sqlite3'
   }
  end
  
  def self?
    false #Application database is not yet supported.
  end
  
  def name_prefix
    @@name_prefix = self?() ? 'kopal_' : ''
  end

  def migrate
    establish_connection
    ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
    ActiveRecord::Migrator.migrate("#{KOPAL_ROOT}/lib/db/migrate/", ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
    if self?()
      Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
    end
  end
  
  #Connect to Kopal databse in present environment
  def establish_connection
    ActiveRecord::Base.establish_connection connection
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
end
