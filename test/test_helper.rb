ENV["RAILS_ENV"] = "test"
ENV['RAILS_ROOT'] ||= File.dirname(__FILE__) + '/../../../..' 
require 'test/unit'
require File.expand_path(File.join(ENV['RAILS_ROOT'], 'config/environment.rb'))
require 'test_help'
require 'rake'

def reload_kopal_schema
  ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
  Kopal::Database.establish_connection
  #ActiveRecord::Base.connection.drop_database name
  sqlite3_file = File.join(RAILS_ROOT, Kopal::Database.connection[:database])
  FileUtils.rm(sqlite3_file) if File.exists? sqlite3_file
  Kopal::Database.migrate
end

class ActiveSupport::TestCase
  #TODO: Need to reset database after every test.
  reload_kopal_schema
  # Add more helper methods to be used by all tests here...
end
