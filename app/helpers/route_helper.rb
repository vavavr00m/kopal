#Static routes. These ruotes are usually one-way, that is they only need to be
#generated, not recognised, so shouldn't really be in <tt>routes.rb</tt>. [RFC]
module RouteHelper

  def signin_path
    home_path(:action => 'signin')
  end

  def signout_path
    home_path(:action => 'signout')
  end

  def friend_path hash = {}
    hash[:action] = 'friend'
    home_path hash
  end
end