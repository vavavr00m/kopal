namespace :kopal do

  desc "Performs first time tasks."
  task :first_time => :environment do
    Rake::Task["db:create_indexes"].invoke
    Kopal::Model.perform_first_time_tasks
    puts "Your default password has been set as \"#{Kopal::Preference::DEFAULT_PASSWORD}\", " +
      "please change it."
    puts "Thank you for using Kopal."
  end
  
  desc "Upgrade database after updating kopal-rails gem"
  task :upgrade => :environment do
    Rake::Task["db:create_indexes"].invoke
  end

  namespace :db do

    #desc "Removes kopal specific tables from the database."
    task :clear do
    end

    #desc "Always call with \"--silent\" option. Backup the database in XML format." +
    #  "Example: rake --silent kopal:backup > kopal_backup.xml"
    task :backup do
      Kopal::Database.backup
    end

    task :restore do
      Kopal::Database.restore
    end

    #desc "Revives the database. Clears out all Kopal::Preference deprecations and errors if any."
    task :revive do
      #Backup the database. (Including password, so not like Kopal::Database.backup).
      #Clear the database.
      #Restore the database.
    end

    #LATER: This should be a hidden task, shouldn't be available in the list.
    #desc "Changes prefix of the kopal tables for a given database. Pass old prefix as argument. Reads new prefix from kopal.databse.yml"
    task :change_prefix do
    end
  end

  #TODO: To-implement.
  namespace :theme do
    task :list do
    end

    task :install do
    end

    task :remove do
    end
  end
  
end

