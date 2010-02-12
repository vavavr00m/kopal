namespace :kopal do

  desc "Performs first time tasks."
  task :first_time => :environment do
    Rake::Task['kopal:update'].invoke
    Kopal::KopalModel.perform_first_time_tasks
    puts "Your default password has been set as \"#{Kopal::KopalPreference::DEFAULT_PASSWORD}\", " +
      "please change it."
    puts "Thank you for using Kopal."
  end
  
  desc "Creates/upgrades the database for Kopal."
  task :update => :environment do
    puts "Installing required gems."
    Rake::Task["gems:install"].invoke #Check gem dependencies and install/upgrade them.
    puts "Migrating Kopal specific database changes."
    prev_state, ENV['VERBOSE'] = ENV['VERBOSE'], false.to_s
    Rake::Task["kopal:migrate_database"].invoke
    ENV['VERBOSE'] = prev_state
  end

  #TODO: Use "hg" command if found, so this way we can know the revision number and
  #update .hg_archival.txt file.
  #If can't determine the upgraded revision, delete this file.
  desc "Fetches new release from Internet, then updates the plugin.\n" +
    "Pass REVISION for hg revision, default is tip-stable or tip-preview based on the revision installed."
  #Developers, running task will delete everything inside kopal plugin folder. So,
  #BACKUP before you run this.
  #This happened to me, and I lost my precious coding of two days (and bloody NetBeans,
  #simply closed every deleted file, without giving a chance to save).
  task :upgrade => :environment do
    include FileUtils
    require_dependency Kopal.root.join("vendor", "patched_recursive_http_fetcher").to_s
    kopal_hg = 'http://kopal.googlecode.com/hg/'
    version_path = "#{kopal_hg}VERSION.txt"
    tip_stable = "tip-preview" #For the moment.
    tip_preview = "tip-preview"
    current = Kopal::Version.current
    plugins_path = Rails.root.join("vendor", "plugins")
    puts "ERROR: vednor/plugins is not writable!" and exit unless
      File.writable? plugins_path
    revision = ENV['REVISION']
    Kopal[:meta_upgrade_last_check] = Time.now
    if revision.blank?
      puts "Checking if a new release is available."
      fetched = Kopal::Version.new(
        Kopal.fetch("#{version_path}?r=#{tip_stable}").response.body)
      revision = "tip-#{current.software_channel}"
      if revision == tip_preview
        #First check if a higher stable version is available in current release.
        if fetched.compare(current) > 0
          revision = tip_stable
        else
          fetched = Kopal::Version.new(
          Kopal.fetch("#{version_path}?r=#{revision}").response.body)
          if fetched.compare(current) < 1
            puts "No new release is available."
            exit
          end
        end
      else #tip-stable
        if fetched.compare(current) < 1
          puts "No new release is available."
          exit
        end
      end
      puts "New release #{fetched} is available. Downloading."
    end
    temp_kopal_folder = "kopal-temp-#{Time.now.tv_sec}"
    temp_kopal_path = "#{plugins_path}/#{temp_kopal_folder}"
    puts "Downloading in vendor/plugins/#{temp_kopal_folder}"
    mkdir_p temp_kopal_path
    Dir.chdir(temp_kopal_path) do
      fetcher = PatchedRecursiveHTTPFetcher.new("#{kopal_hg}?r=#{revision}", -1)
      fetcher.fetch
    end
    remove_dir KOPAL_ROOT, true
    mv temp_kopal_path, KOPAL_ROOT
    puts "\nUpgraded Kopal to version #{fetched} from #{current}."
    puts "NOTE: Please run \"rake kopal:update RAILS_ENV=production\" to update Kopal.\n\n"
  end

  desc "Migrates Kopal specific migrations only."
  task :migrate_database do
    Kopal::KopalModel.migrate!
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

  #desc "Revives the database. Clears out all deprecations and errors if any."
  task :revive do
    #Backup the database. (Including password, so not like Kopal::Database.backup).
    #Clear the database.
    #Restore the database.
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


  Rake::Task["db:migrate"].enhance do
    Rake::Task["kopal:migrate_database"].invoke
  end
  
end

