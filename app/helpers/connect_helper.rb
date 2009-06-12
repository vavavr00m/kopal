module ConnectHelper

  def generate_friendship_request_link identity
    p = ProfileUser.new
    identity + '?kopal.discovery=true&kopal.subject=friendship-request&kopal.friend-identity=' +
      p.kopal_identity
  end
end
