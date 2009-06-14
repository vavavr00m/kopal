#This file is meant for Kopal as a plugin.
## desc "Explaining what the task does"
## task :kopal do
##   # Task goes here
## end
#
#namespace :kopal do
#  desc "Called automatically with db:migrate. Creates/upgrades the database for Kopal."
#  task :upgrade do
#    Kopal::migrate()
#  end
#
#  desc "Removes kopal specific tables from the database."
#  task :clear_database do
#  end
#
#  #TODO: To-implement.
#  namespace :theme do
#    task :list do
#    end
#
#    task :install do
#    end
#
#    task :remove do
#    end
#  end
#end
#
#Rake::Task["db:migrate"].enhance do
#  Rake::Task["kopal:upgrade"].invoke
#end
#
