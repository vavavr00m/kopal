class Kopal::Profile < Kopal::Model
  
  field :identifier, :type => String
  field :name, :type => String
  field :kopal_identity, :type => String
  field :status_message, :type => String
  field :base64_encoded_private_key, :type => String
  
  #indices
  index :identifier, :unique => true

  embeds_one :feed_data, :class_name => "Kopal::FeedData", :dependent => :destroy
  references_many :accounts, :class_name => "Kopal::Account", :dependent => :destroy
  #references_many :preferences, :class_name => "Kopal::Preference"
  references_many :comments, :class_name => "Kopal::ProfileComment", :dependent => :destroy
  references_many :friends, :class_name => "Kopal::ProfileFriend", :dependent => :destroy
  references_many :pages, :class_name => "Kopal::ProfilePage", :dependent => :destroy

  validates_presence_of :identifier
  validates_uniqueness_of :identifier
  validates_presence_of :feed_data
  
  class << self
    
    def default_profile
      where(:identifier => 
        Rails.application.config.kopal.default_profile_identifier).first
    end
    
  end
  
  def to_s
    name.to_s
  end
  
  def name
    self[:name].presence || identifier
  end
  
  def superusers
    accounts.superusers
  end
  
  def feed
    feed_data.to_kopal_feed
  end
  
end