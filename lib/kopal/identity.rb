class Kopal::Identity
  include Kopal::KopalHelper

  attr_reader :identity, :uri
  alias to_s identity

  def initialize url
    @identity = normalise_url(url)
    @uri = URI.parse(@identity)
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

  def friendship_state_url requester_identity
    connect_url_with_identity(requester_identity) + '&kopal.subject=friendship-state'
  end

  def friendship_update_url state, friendship_key, requester_identity
    connect_url_with_identity(requester_identity) + '&kopal.subject=friendship-update&kopal.state=' +
      state + '&kopal.friendship-key=' + friendship_key.to_s
  end

private

  def connect_url
    identity + '?kopal.connect=true'
  end

  def connect_url_with_identity requester_identity
    connect_url + '&kopal.identity=' + requester_identity.to_s
  end
  
end