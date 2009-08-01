namespace :kopal do
  desc "Called automatically with db:migrate. Creates/upgrades the database for Kopal."
  task :upgrade => :environment do
    #TODO: Fetch the latest version number from Inernet, download and install it if necessary.
    Rake::Task["gems:install"].invoke #Check gem dependencies and install/upgrade them.
    Kopal::Database.migrate
  end

  #desc "Removes kopal specific tables from the database."
  task :clear_database do
  end

  #desc "Always call with \"--silent\" option. Backup the database in XML format." +
  #  "Example: rake --silent kopal:backup > kopal_backup.xml"
  task :backup do
    Kopal::Database.backup
  end

  task :restore do
    Kopal::Database.restore
  end

  #LATER: This should be a hidden task, shouldn't be available in the list.
  #desc "Changes prefix of the kopal tables for a given database. Pass old prefix as argument. Reads new prefix from kopal.databse.yml"
  task :change_prefix do
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

Rake::Task["db:migrate"].enhance do
  Rake::Task["kopal:upgrade"].invoke
end

