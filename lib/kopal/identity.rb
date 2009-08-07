class Kopal::Identity
  include Kopal::KopalHelper

  attr_reader :identity, :uri
  alias to_s identity

  def initialize url
    @identity = normalise_url(url)
    @uri = URI.parse(@identity)
    @profile_user = Kopal::ProfileUser.new
  end

  def of_profile_user?
    @profile_user.kopal_identity == identity
  end

  #Checks if the given url is a valid Kopal Identity.
  #Ends with "!" since performs a network activity.
  def validate!
    #TODO: Write me
    raise NotImplementedError
  end

  def profile_image_url
    connect_url + '&kopal.subject=image'
  end

  def feed_url
    identity + '?kopal.feed=true'
  end
  alias kopal_feed_url feed_url

  def discovery_url
    connect_url + '&kopal.subject=discovery'
  end

  def friendship_request_url
    connect_url + '&kopal.subject=friend'
  end

  def friendship_state_url
    connect_url_with_identity + '&kopal.subject=friendship-state'
  end

  def friendship_update_url state, friendship_key = nil
    friendship_key ||= Kopal::UserFriend.find_or_initialise_readonly(identity).friendship_key
    connect_url_with_identity + '&kopal.subject=friendship-update&kopal.state=' + 
      state + '&kopal.friendship-key=' + friendship_key.to_s
  end

private

  def connect_url
    identity + '?kopal.connect=true'
  end

  def connect_url_with_identity
    #raise NoMethodError, "Can't generate for Profile user" if of_profile_user?
    connect_url + '&kopal.identity=' + @profile_user.kopal_identity.to_s
  end
  
end