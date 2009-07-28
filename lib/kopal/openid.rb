require 'openid'

#At present, Kopal's implentation of OpenID is very limited and specific to Kopal's needs.
#It is expected to grow wide in future.
module Kopal::OpenID
  class OpenIDError < Kopal::KopalError; end
  class OpenIDInvalid < OpenIDError; end
  class AuthenticationRequired < OpenIDError; end


  module ControllerHelper
    def authenticate_with_openid &block
      if params[:openid_complete].nil?
        k = Kopal::OpenID::Consumer.begin(params, session, &block)
        redirect_to(k.openid_request.redirect_url(
          Kopal.identity.to_s, Kopal.route.openid_consumer_complete)) unless
          k.error?
      else
        Kopal::OpenID::Consumer.complete(params, request, session, &block)
      end
    end
  end

  #Based on OpenIdAuthentication plugin.
  #OPTIMIZE: Doesn't recognises XRIs.
  def self.normalise_identifier identifier

    identifier = identifier.to_s.strip
    identifier = "http://#{identifier}" unless identifier =~ /^https?:/i

    # strip any fragments
    identifier.gsub!(/\#(.*)$/, '')

    begin
      uri = URI.parse(identifier)
      uri.scheme = uri.scheme.downcase  # URI should do this
      identifier = uri.normalize.to_s
    rescue URI::InvalidURIError
      raise OpenIDInvalid, "#{identifier} is not an OpenID identifier"
    end

    return identifier
  end
end


require_dependency 'kopal/openid/session_store'
require_dependency 'kopal/openid/server'
require_dependency 'kopal/openid/consumer'