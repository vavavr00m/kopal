class Kopal::Identity
  include KopalHelper

  attr_reader :identity, :uri
  alias to_s identity

  def initialize url
    @identity = normalise_url(url)
    @uri = URI.parse(@identity)
    @profile_user = ProfileUser.new
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

  def feed_url
    identity + '?kopal.feed=true'
  end

  def discovery_url
    connect_url + '&kopal.subject=discovery'
  end

  def friendship_request_url
    friendship_update_url 'request'
  end

  def friendship_rejection_url
    friendship_update_url 'rejected'
  end

  def friendship_update_url state
    connect_url_with_identity + '&kopal.subject=friendship-update&kopal.state=' + state
  end

private

  def connect_url
    identity + '?kopal.connect=true'
  end

  def connect_url_with_identity
    #raise NoMethodError, "Can't generate for Profile user" if of_profile_user?
    connect_url + '&kopal.identity=' + @profile_user.kopal_identity
  end
  
end