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
  
  def self.migrate
  end

end
