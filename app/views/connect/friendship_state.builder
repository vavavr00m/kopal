xml.FriendshipState :state => @friend.friendship_state, 
  :identity => normalise_url(params[:"kopal.identity"]) { |xm|
    xm.FriendshipKeyEncrypted Base64.encode64
      @profile_user.private_key!.private_encrypt @friend.friendship_key
  }