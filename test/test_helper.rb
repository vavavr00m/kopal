ENV["RAILS_ENV"] = "test"
ENV['RAILS_ROOT'] ||= File.dirname(__FILE__) + '/../../../..'
begin
  loop = false
  environment_file = File.expand_path(File.join(ENV['RAILS_ROOT'], 'config/environment.rb'))
  unless File.exists? environment_file
    ENV['RAILS_ROOT'] = File.dirname(__FILE__) + '/../kopal-app' #in development mode.
    loop = true
  end
end while loop
  
require 'test/unit'
require environment_file
require 'test_help'
require 'rake'

def reload_kopal_schema
  ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
  database = Kopal::Database.new
  database.establish_connection
  #ActiveRecord::Base.connection.drop_database name
  sqlite3_file = File.join(RAILS_ROOT, database.connection[:database])
  FileUtils.rm(sqlite3_file) if File.exists? sqlite3_file
  database.migrate!
end

class ActiveSupport::TestCase
  #TODO: Need to reset database after every test.
  reload_kopal_schema
  # Add more helper methods to be used by all tests here...
end
