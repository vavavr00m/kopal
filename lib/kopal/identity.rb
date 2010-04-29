class Kopal::Identity
  include Kopal::KopalHelper

  attr_reader :identity, :identity_url
  alias to_s identity
  alias identity_uri identity_url #Will think about the difference later.

  #Must be _identity function_ after first normalise_kopal_identity(id).
  #i.e.,
  #  normalise_kopal_identity(normalise_kopal_identity(id)) = normalise_kopal_identity(id)
  #TODO: Write tests.
  #
  #@return [String] normalised Kopal Identity
  def self.normalise_identity identifier
    begin
      identifier = Kopal::KopalHelperWrapper.new.normalise_url identifier
      identifier.gsub!(/\#(.*)$/, '') # strip any fragments
      identifier += '/' unless identifier[-1].chr == '/'
      raise URI::InvalidURIError if identifier['?'] #No query string
      #What about "localhost"?
      #URLs must have atleast on dot.
      #raise URI::InvalidURIError unless identifier =~
        #/^[^.]+:\/\/[0-9a-z]+\.[0-9a-z]+/i #Internationalised domains?, IPv6 addresses?
    rescue URI::InvalidURIError
      raise Kopal::KopalIdentityInvalid, "#{identifier} is not a valid Kopal Identity."
    end
    return identifier
  end

  def initialize url
    @identity = self.class.normalise_identity(url)
    @identity_url = Kopal::Url.new @identity
  end

  #Checks if the given url is a valid Kopal Identity.
  #Ends with "!" since performs a network activity.
  def validate_over_network!
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

  def profile_image_url hash = {}
    build_kc_url hash.update :"kopal.subject" => 'image'
  end

  def feed_url hash = {}
    identity_url.dup.update_parameters hash.update :"kopal.feed" => 'true'
  end
  alias kopal_feed_url feed_url

  def discovery_url hash = {}
    build_kc_url hash.update :"kopal.subject" => 'discovery'
  end

  def request_friendship_url hash = {}
    unless hash.is_a? Hash
      DeprecatedMethod.here "Pass an Hash instead of String."
      hash = { :'kopal.identity' => hash}
    end
    required_params(hash, :'kopal.identity')
    build_kc_url hash.update :"kopal.subject" => 'request-friendship'
  end

  def friendship_request_url hash = {}
    unless hash.is_a? Hash
      DeprecatedMethod.here "Pass an Hash instead of String."
      hash = { :'kopal.identity' => hash}
    end
    required_params(hash, :'kopal.identity')
    build_kc_url hash.update :"kopal.subject" => 'friendship-request'
    
  end

  def friendship_state_url hash = {}
    unless hash.is_a? Hash
      DeprecatedMethod.here "Pass an Hash instead of string."
      hash = { :'kopal.identity' => hash}
    end
    required_params(hash, :'kopal.identity')
    build_kc_url hash.update :'kopal.subject' => 'friendship-state'
  end

  #In deprecated benhaviour, hash is state.
  def friendship_update_url hash = {}, friendship_key = '', requester_identity = ''
    unless hash.is_a? Hash
      DeprecatedMethod.here "Pass an Hash instead of string."
      hash = { :'kopal.state' => hash, :'kopal.identity' => requester_identity,
        :'kopal.friendship-key' => friendship_key}
    end
    required_params(hash, :'kopal.identity', :'kopal.state', :'kopal.friendship-key')
    build_kc_url hash.update :"kopal.subject" => 'friendship-update'
  end

  #TODO: Deprecate it. Sigin-In is part of OpenID not Kopal Connect.
  def signin_request_url returnurl = nil
    query_hash = { :"kopal.subject" => 'signin-request',}
    #RUBYBUG: URI.escape() returns same value for http://example.org/?a=b&c=d without second argument
    #  or passing it as URI::REGEXP::UNSAFE.
    #URI.escape 'http://example.org/?a=b&c=d' #=> "http://example.org/?a=b&c=d"
    #URI.escape 'http://example.org/?a=b&c=d', URI::REGEXP::UNSAFE #=> "http://example.org/?a=b&c=d"
    #
    #query_hash.update :'kopal.returnurl' => URI.escape(returnurl, '?=&#:/') unless returnurl.blank?
    query_hash.update :'kopal.returnurl' => CGI.escape(returnurl) unless returnurl.blank?
    build_kc_url query_hash
  end

private

  def build_kc_url query_hash
    uri = identity_uri.dup
    uri.update_parameters :"kopal.connect" => 'true'
    uri.update_parameters query_hash
  end

  def required_params params, *args
    args.each { |p|
      raise ArgumentError, "Expect #{p} to be present" if params[p].blank?
    }
  end
  
end