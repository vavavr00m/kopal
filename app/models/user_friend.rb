class UserFriend < ActiveRecord::Base

  FRIENDSHIP_STATES = [
    :pending,
    :friend
  ]

  validates_presence_of :kopal_identity, :name, :friendship_state
  validates_uniqueness_of :kopal_identity

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

  def url_kopal_discovery
    self[:identity] + "?kopal.discovery=true&kopal.subject=discovery"
  end

  def url_kopal_feed
    
  end
end
