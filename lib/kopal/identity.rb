class Kopal::Identity
  include KopalHelper

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

  def connect_url
    @identity + '?kopal.connect=true'
  end

  def feed_url
    @identity + '?kopal.feed=true'
  end
  
end