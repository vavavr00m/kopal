require "#{File.dirname(__FILE__)}/test_helper" 

class RoutingTest < Test::Unit::TestCase

  def setup
    Kopal.draw_routes '/profile2/'
  end

  def test_kopal_base_route_is_profile2
    assert_equal '/profile2', Kopal.base_route
  end

  def test_kopal_route_root
    assert_equal Kopal.base_route + '/', Kopal.route.root
    ['', '/'].each { |r|
      assert_recognition :get, '', :controller => 'kopal/home', :action => 'index',
        :trailing_slash => true
    }
  end
  
  def test_kopal_route_home
    assert_equal Kopal.base_route + '/', Kopal.route.home
    assert_recognition :get, '/home/', :controller => 'kopal/home',
      :action => 'index', :trailing_slash => true
  end

  def test_kopal_route_stylesheet
    assert_equal Kopal.base_route + '/home/stylesheet/home.css', Kopal.route.stylesheet('home')
    assert_equal Kopal.route.stylesheet('home'), Kopal.route.stylesheet(:id => 'home')
    assert_recognition :get, '/home/stylesheet/home.css', :controller => 'kopal/home',
      :action => 'stylesheet', :id => 'home', :format => 'css', :trailing_slash => false
  end

  def test_kopal_route_profile_image
    assert_equal Kopal.base_route + '/home/profile_image/profile_user.jpeg', Kopal.route.profile_image
    assert_recognition :get, '/home/profile_image', :controller => 'kopal/home',
      :action => 'profile_image', :trailing_slash => true #FIXME: trailing slash should come false.
  end

  def test_kopal_route_feed
    assert_equal Kopal.base_route + '/home/feed.kp.xml', Kopal.route.feed
    assert_recognition :get, '/home/feed.kp.xml', :controller => 'kopal/home',
      :action => 'feed', :format => 'xml', :trailing_slash => false
  end

  def test_kopal_route_signin
    assert_equal Kopal.base_route + '/home/signin/', Kopal.route.signin
    assert_recognition :get, '/home/signin/', :controller => 'kopal/home',
      :action => 'signin', :trailing_slash => true
  end

  def test_kopal_route_signout
    assert_equal Kopal.base_route + '/home/signout/', Kopal.route.signout
    assert_recognition :get, '/home/signout/', :controller => 'kopal/home',
      :action => 'signout', :trailing_slash => true
  end

  def test_kopal_route_friend
    assert_equal Kopal.base_route + '/home/friend/', Kopal.route.friend
    assert_recognition :get, '/home/friend/', :controller => 'kopal/home',
      :action => 'friend', :trailing_slash => true
  end

  def test_kopal_route_organise
    assert_equal Kopal.base_route + '/organise/', Kopal.route.organise
    assert_recognition :get, '/organise/', :controller => 'kopal/organise',
      :action => 'index', :trailing_slash => true
  end

  def test_kopal_route_organise_friend
    assert_equal Kopal.base_route + '/organise/friend/', Kopal.route.organise_friend
    assert_recognition :get, '/organise/friend/', :controller => 'kopal/organise',
      :action => 'friend', :trailing_slash => true
  end

  def test_kopal_route_edit_profile
    assert_equal Kopal.base_route + '/organise/edit_profile/', Kopal.route.edit_profile
    assert_recognition :get, '/organise/edit_profile/', :controller => 'kopal/organise',
      :action => 'edit_profile', :trailing_slash => true
  end

  def test_kopal_route_change_password
    assert_equal Kopal.base_route + '/organise/change_password/', Kopal.route.change_password
    assert_recognition :get, '/organise/change_password/', :controller => 'kopal/organise',
      :action => 'change_password', :trailing_slash => true
  end
  
private
  
  def assert_recognition(method, path, options)
    result = ActionController::Routing::Routes.recognize_path(Kopal.base_route + path,
      :method => method)
    assert_equal options, result
  end
end

