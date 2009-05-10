#Kopal
KOPAL_ROOT = File.expand_path(File.dirname(__FILE__) + '/..') unless defined? KOPAL_ROOT

#== <tt>kopal_config.yml</tt>.
#<tt>kopal_config.yml</tt> contains configuration options for Kopal as a Hash, keys made of +:symbols+.
#[<tt>:authntication_method</tt>]
#  Default is +:builtin+, may have a *string* value containing
#  the name of authentication method of +ApplicationController+ which acts in following ways.
#  If the user is authenticated, this method should return true, otherwise should
#  authenticate the user (may redirect to the authentication page for authentication) and
#  return +false+ or +nil+.
#[<tt>:account_password</tt>] Required if +:authentication_method+ is +:builtin+.
module Kopal
  DISCOVERY_PROTOCOL_REVISION = "0.1.alpha"
  FEED_PROTOCOL_REVISION = "0.1.alpha"
  CONFIG_FILE_ADDRESS = RAILS_ROOT + '/config/kopal.yml'

  def self.migrate
    last_revision = 0
    new_last_revision = 0
    migration_folder = KOPAL_ROOT + '/lib/db/migrate'
    if File.exists?(CONFIG_FILE_ADDRESS)
      #kopal is installed.
      last_revision = KopalPref.last_migration_revision
    else
      #Kopal is not installed.
      create_config_file
    end
    Dir.foreach(migration_folder) { |m|
      next if m.to_i <= last_revision
      require migration_folder + '/' + m
      #TODO: Replace it with some Rails's method if exists.
      m.gsub(/^[0-1]/, '').gsub(/^_+/, '').camelcase.constantize.up
      new_last_revision = m.to_i
    }
    KopalPref.last_migration_revision = new_last_revision
  end

  def self.create_config_file
    return if File.exists?(CONFIG_FILE_ADDRESS)
    #default data -
    @@config = {
      :authentication_method => :builtin,
      :account_password => 'secret01'
    }
    File.open(CONFIG_FILE_ADDRESS, "w") { |out|
      out << YAML::dump(@@config)
    }
  end

  def self.read_config_file
    #No call to create_config_file from here, an Invalid file error will
    # => make sure that Kopal is not installed.
    @@config = YAML::load_file(CONFIG_FILE_ADDRESS)
  end
  class << self; alias_method :reload_config_file, :read_config_file; end

  def self.[] index
    read_config_file unless @@config
    @@config[index]
  end
end
