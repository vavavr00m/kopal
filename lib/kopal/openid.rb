require 'openid'

#At present, Kopal's implentation of OpenID is very limited and specific to Kopal's needs.
#It is expected to grow wide in future.
module Kopal::OpenID
  class OpenIDError < Kopal::KopalError; end
  class AuthenticationRequired < OpenIDError; end
end

require_dependency 'kopal/openid/session_store'
require_dependency 'kopal/openid/server'
require_dependency 'kopal/openid/consumer'