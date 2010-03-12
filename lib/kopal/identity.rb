class Kopal::Identity
  include Kopal::KopalHelper

  attr_reader :identity, :identity_uri
  alias to_s identity

  def initialize url
    @identity = normalise_url(url)
    @identity_uri = Kopal::Url.new @identity
  end

  #Checks if the given url is a valid Kopal Identity.
  #Ends with "!" since performs a network activity.
  def validate!
    #TODO: Write me
    raise NotImplementedError
  end

  def escaped_uri
    URI.escape to_s
  end

  #Removes http(s):// and trailing slash if only domain.
  def simplified
    r = to_s.gsub(/^[^\.]*:\/\//, '')
    r[-1] = '' if r.index('/') == r.size-1 #same as r.count('/') == 1
    r
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

  def friendship_request_url requester_identity
    build_connect_url :"kopal.identity" => requester_identity,
      :"kopal.subject" => 'friendship-request'
    
  end

  def friendship_state_url requester_identity
    connect_url_with_identity(requester_identity) + '&kopal.subject=friendship-state'
  end

  def friendship_update_url state, friendship_key, requester_identity
    connect_url_with_identity(requester_identity) + '&kopal.subject=friendship-update&kopal.state=' +
      state + '&kopal.friendship-key=' + friendship_key.to_s
  end

  #TODO: Deprecate it. Sigin-In is part of OpenID not Kopal Connect.
  def signin_request_url returnurl = nil
    query_hash = { :"kopal.subject" => 'signin-request',}
    #RUBYBUG: URI.escape() returns same value for http://example.org/?a=b&c=d without second argument
    #  or passing it as URI::REGEXP::UNSAFE.
    #URI.escape 'http://example.org/?a=b&c=d' #=> "http://example.org/?a=b&c=d"
    #URI.escape 'http://example.org/?a=b&c=d', URI::REGEXP::UNSAFE #=> "http://example.org/?a=b&c=d"
    query_hash.update :'kopal.returnurl' => URI.escape(returnurl, '?=&#:/') unless returnurl.blank?
    build_connect_url query_hash
  end

private

  #prefix "new_" signifies that for each call, it will return a new object.
  def new_connect_url
    uri = identity_uri.dup
    uri.query_hash.update :"kopal.connect" => 'true'
    uri
  end

  def build_connect_url query_hash
    uri = identity_uri.dup
    uri.query_hash.update :"kopal.connect" => 'true'
    uri.query_hash.update query_hash
    uri.build_query
    uri.to_s
  end
  
  def connect_url
    identity + '?kopal.connect=true'
  end

  def connect_url_with_identity requester_identity
    connect_url + '&kopal.identity=' + requester_identity.to_s
  end
  
end