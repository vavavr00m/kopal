class Kopal::KopalAccount < Kopal::KopalModel
  set_table_name "#{name_prefix}kopal_account"

  DEFAULT_PROFILE_ACCOUNT_ID = 0

  has_many :preferences, :class_name => 'Kopal::KopalPreference'
  #@deprecated.
  has_many :preferences_for_feed, :class_name => 'Kopal::KopalPreference', :conditions => 'preference_name LIKE \'feed_%\'' # no '"' for LIKE!
  has_many :comments, :class_name => 'Kopal::ProfileComment'
  has_many :recent_comments, :class_name => 'Kopal::ProfileComment', :order => 'created_at DESC', :limit => 20
  #NOTE: There is a caveat, Previous friends() meant present's friends().friend()
  has_many :all_friends, :class_name => 'Kopal::ProfileFriend'
  def pending_friends
    DeprecatedMethod.here("Use all_friends().pending() instead.")
    all_friends.pending
  end
  
  def waiting_friends
    DeprecatedMethod.here("Use all_friends().waiting() instead.")
    all_friends.waiting
  end

  def friends
    DeprecatedMethod.here("Use all_friends().friend() instead.")
    all_friends.friend
  end
  has_many :pages, :class_name => 'Kopal::ProfilePage'
  #has_many :profile_visitors
  #Duplicated in ProfileUser#status_message, remove it after one commit.
  has_one :status_message, :class_name => 'Kopal::KopalPreference', :conditions => ['preference_name = ?', 'profile_status_message']
  #has_one :last_seen, :last_signed

  validates_presence_of :identifier_from_application, :unless => Proc.new {|p| p.id == 0}
  validates_uniqueness_of :identifier_from_application

  def self.create_default_profile_account!
    raise 'Default profile account already exists!' if self.find_by_id(0)
    self.transaction do
      d = self.new
      d.id = DEFAULT_PROFILE_ACCOUNT_ID
      d.identifier_from_application = nil
      d.save!
      Kopal::KopalPreference.save_password d.id, Kopal::KopalPreference::DEFAULT_PASSWORD
      return true #and not saved password hash.
    end
  end

  def self.create_account! identifier_from_application
    a = self.new
    a.identifier_from_application = identifier_from_application
    a.save!
  end

  def self.default_profile_account
    self.find(0)
  end
end