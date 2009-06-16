#== UserFriend Fields
# * <tt>kopal_identity (string, not null, unique)</tt>
# * <tt>kopal_feed (text, not null)</tt>
# * <tt>friendship_state (string, not null)</tt>
# * <tt>friend_group (string / friend ids by comma)</tt>
#
#== UserFriend Indicies
# * <tt>kopal_identity, unique</tt>
#
class UserFriend < ActiveRecord::Base

  FRIENDSHIP_STATES = [
    :pending, #You need to accept/reject this request.
    :waiting, #You send friendship request, waiting for approval.
    :friend
  ]

  validates_presence_of :kopal_identity, :kopal_feed, :friendship_state
  validates_uniqueness_of :kopal_identity
  validates_inclusion_of :friendship_state, :in => FRIENDSHIP_STATES.map { |i| i.to_s }

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

  def kopal_identity
    Kopal::Identity.new self[:kopal_identity]
  end

  #Value can be a String or Kopal::Identity
  def kopal_identity= value
    self[:kopal_identity] = value.to_s
  end

  def kopal_feed
    @_kopal_feed ||= Kopal::Feed.new self[:kopal_feed]
  end
  alias feed kopal_feed

  def kopal_feed= value
    self[:kopal_feed] = value.to_s
  end
end
