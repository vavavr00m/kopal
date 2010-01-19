ENV["RAILS_ENV"] = "test"
ENV['RAILS_ROOT'] ||= File.dirname(__FILE__) + '/../../../..'
environment_file = ''
2.times do
  environment_file = File.expand_path(File.join(ENV['RAILS_ROOT'], 'config/environment.rb'))
  unless File.exists? environment_file
    ENV['RAILS_ROOT'] = File.dirname(__FILE__) + '/../../kopal-app' #in development mode.
  end
end
  
require 'test/unit'
require environment_file
require 'test_help'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'tasks/rails'

#TODO: Test on multiple DBMSes.

Rake::Task['db:migrate:reset'].invoke
#puts "BEING CALLED"
#This line is being called 2 times, while above rake task executes only once!
Kopal::KopalModel.perform_first_time_tasks unless Kopal::KopalAccount.find_by_id(0)

class ActiveSupport::TestCase
  # Add more helper methods to be used by all tests here...
end
