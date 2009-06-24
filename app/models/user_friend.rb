#== UserFriend Fields
# * <tt>kopal_identity (string, not null, unique)</tt>
# * <tt>kopal_feed (text, not null)</tt>
# * <tt>friendship_key (string(32,64), not null)</tt>
# * <tt>friendship_state (string, not null)</tt>
# * <tt>public_key (string, not null)</tt>
# * <tt>friend_group (string / friend ids by comma)</tt>
#
#== UserFriend Indices
# * <tt>kopal_identity, unique</tt>
#
class UserFriend < ActiveRecord::Base

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

  validates_presence_of :kopal_identity, :kopal_feed, :friendship_state,
    :friendship_key, :public_key
  validates_uniqueness_of :kopal_identity
  validates_inclusion_of :friendship_state, :in => FRIENDSHIP_STATES.map { |i| i.to_s }
  validates_length_of :friendship_key, :in => FRIENDSHIP_KEY_LENGTH

  #Initialise a UserFriend instance that is not and can not be associated
  #with a database row.
  def new_readonly
    r = self.new
    r.readonly!
    return r
  end

  def validate
    begin
      normalise_url(self[:kopal_identity])
    rescue Kopal::KopalIdentityInvalid
      errors.add(:kopal_identity, "is not a valid Kopal Identity.")
    end
    begin
      public_key
    rescue OpenSSL::PKey::RSAError
      errors.add(:public_key, "Invalid Public Key.")
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

  def kopal_identity
    Kopal::Identity.new self[:kopal_identity]
  end

  #Value can be a String or Kopal::Identity
  def kopal_identity= value
    self[:kopal_identity] = value.to_s
  end

  def public_key
    OpenSSL::PKey::RSA.new self[:public_key]
  end

  #Accepts string and instance of OpenSSL::PKey::RSA
  def public_key= value
    self[:public_key] = value.to_s
  end

  def kopal_feed
    @_kopal_feed ||= Kopal::Feed.new self[:kopal_feed]
  end
  alias feed kopal_feed

  def kopal_feed= value
    self[:kopal_feed] = value.to_s
  end
end
