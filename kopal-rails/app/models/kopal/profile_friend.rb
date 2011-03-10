class Kopal::ProfileFriend < Kopal::KopalModel

  field :friend_kopal_identity
  field :friend_kopal_feed
  field :friendship_key
  field :friendship_state
  field :friend_public_key
  field :friend_group

  index :friend_kopal_identity, :unique => true

  #Valid friendship states that can go to database.
  FRIENDSHIP_STATES = [
    :pending, #You need to accept/reject this request.
    :waiting, #You send friendship request, waiting for approval.
    :friend
  ]

  #All possible friendship states
  ALL_FRIENDSHIP_STATES = FRIENDSHIP_STATES.concat [
    :none,
    :rejected
  ]

  #At present, Kopal always creates a key of length 40, while accepting of any
  #valid length.
  FRIENDSHIP_KEY_LENGTH = 32..64

  named_scope :pending, :conditions => {:friendship_state => 'pending'}
  named_scope :waiting, :conditions => {:friendship_state => 'waiting'}
  named_scope :friend,  :conditions => {:friendship_state => 'friend' }

  validates_presence_of :friend_kopal_identity, :friend_kopal_feed, :friendship_state,
    :friendship_key, :friend_public_key
  validates_uniqueness_of :friend_kopal_identity
  validates_inclusion_of :friendship_state, :in => FRIENDSHIP_STATES.map { |i| i.to_s }
  validates_length_of :friendship_key, :in => FRIENDSHIP_KEY_LENGTH

  #Initialise a UserFriend instance that is not and can not be associated
  #with a database row.
  #Good way represent a friend? or deprecate?
  def self.find_or_initialise_readonly kopal_account_id, friend_kopal_identity
    r = self.
      find_or_initialize_by_kopal_account_id_and_friend_kopal_identity kopal_account_id,
      friend_kopal_identity
    r.readonly!
    return r
  end

  def validate
    begin
      Kopal::Identity.normalise_identity(self[:friend_kopal_identity])
    rescue Kopal::KopalIdentityInvalid
      errors.add(:friend_kopal_identity, "is not a valid Kopal Identity.")
    end
    begin
      friend_public_key
    rescue OpenSSL::PKey::RSAError
      errors.add(:friend_public_key, "Invalid Public Key.")
    end
    errors.add(:friendship_key, "is not a valid hexadecimal stream.") unless
      valid_hexadecimal? friendship_key
  end

  def friend_groups
    ids = read_attribute(:friend_group).to_s.split(',')
    #for each get the frien group name from UserFriendGroup
  end

  def add_friend_group group_name
    #Get Id from UserFriendGroup
    #Add it and write to :friend_group attribute.
  end

  def remove_friend_group group_name
    
  end

  #Assigns key for new friends.
  def assign_key!
    if friendship_key.blank?
      self[:friendship_key] = random_hexadecimal 40
    end
  end

  def friendship_state
    self[:friendship_state] || 'none'
  end

  def friendship_key= value
    self[:friendship_key] = value.to_s.downcase
  end

  def friend_kopal_identity
    Kopal::Identity.new self[:friend_kopal_identity]
  end

  #Value can be a String or Kopal::Identity
  def friend_kopal_identity= value
    self[:friend_kopal_identity] = value.to_s
  end

  def friend_public_key
    OpenSSL::PKey::RSA.new self[:friend_public_key]
  end

  #Accepts string and instance of OpenSSL::PKey::RSA
  def friend_public_key= value
    self[:friend_public_key] = value.to_s
  end

  def friend_kopal_feed
    @_kopal_feed ||= Kopal::Feed.new self[:friend_kopal_feed]
  end
  alias feed friend_kopal_feed

  def friend_kopal_feed= value
    self[:friend_kopal_feed] = value.to_s
  end
end
