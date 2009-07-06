require "#{File.dirname(__FILE__)}/test_helper" 

class RoutingTest < Test::Unit::TestCase

  def setup
    Kopal.draw_routes '/profile2/'
  end
  
  def test_kopal_route
    assert_recognition :get, '/home/', :controller => 'home', :action => 'index'
  end
  
private
  
  def assert_recognition(method, path, options)
    result = ActionController::Routing::Routes.recognize_path(path, :method => method)
    assert_equal options, result
  end
end

