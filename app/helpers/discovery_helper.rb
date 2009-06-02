module DiscoveryHelper

  def generate_friendship_request_link identity
    p = ProfileUser.new
    identity + '?kopal.talk=true&kopal.subject=friendship-request&kopal.friend-identity=' +
      p.kopal_identity
  end
end
