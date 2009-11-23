require 'openid/store/interface'
#Store the OpenID authentication in session.
class Kopal::OpenID::SessionStore < ::OpenID::Store::Interface

  def initialize session
    @session = session
  end

  def store_association
    
  end
end