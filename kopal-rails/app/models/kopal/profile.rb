class Kopal::Profile < Kopal::Model
  class DefaultProfileExistsAlready < Kopal::Exception::ApplicationError; end;
  
  field :identifier
  index :identifier, :unique => true

  embeds_many :accounts, :class_name => "Kopal::Account"
  embeds_many :preferences, :class_name => "Kopal::Preference"
  embeds_many :comments, :class_name => "Kopal::Comment"
  embeds_many :friends, :class_name => "Kopal::Friend"
  embeds_many :pages, :class_name => "Kopal::Page"

  validates_presence_of :identifier
  validates_uniqueness_of :identifier
  
  class << self
    
    def default_profile
      where(:identifier => 
        Rails.application.config.kopal.default_profile_identifier).first
    end
    
    #@returns [self] default profile
    def create_default_profile!
      raise DefaultProfileExistsAlready if default_profile
      Kopal::Account.create!(:superuser => true, 
        :profile => {:identifier => 'default'}, 
        :user => {:full_name => "Default user"}
      )
    end
  end
  
  def superusers
    accounts.superusers
  end
end