# Kopal

define KOPAL_ROOT = File.expand_path(File.dirname(__FILE__) + '/..') unless defined? KOPAL_ROOT
module Kopal
  DISCOVERY_PROTOCOL_REVISION = "0.1.alpha"
  FEED_PROTOCOL_REVISION = "0.1.alpha"
  CONFIG_FILE_ADDRESS = RAILS_ROOT + '/config/kopal.yml'

  def self.migrate
    revision = 0
    if File.exists?(CONFIG_FILE_ADDRESS)
      #kopal is installed.
      KopalPref.schema_revision
    else
      #Kopal is not installed.
      create_config_file
    end
  end

  def self.create_config_file
    #default data -
  end

  def self.read_config_file
    @@config = YAML::load_file(CONFIG_FILE_ADDRESS)
  end
  class << self; alias_method :reload_config_file, :read_config_file; end

  def self.[] index
    read_config_file unless @@config
    @@config[index]
  end
end
