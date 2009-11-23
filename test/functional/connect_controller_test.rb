require File.dirname(__FILE__) + '/../test_helper'

class Kopal::ConnectControllerTest < ActionController::TestCase

  def test_index_is_reachable
    get :index
    assert_redirected_to Kopal.route.root
  end

  def test_discovery_is_reachable
    get :discovery
    assert_response :success
  end

  def test_friendship_request
    #TODO: Write me.
    get :friendship_request, :"kopal.identity" => 'http://test.host/profile/'
    #Or Kopal[:kopal_identity] = 'http://127.0.0.1:3500/profile/'
    #get :friendship_request, :"koapl.identity" => 'http://127.0.0.1:3500/profile/'
  end

  def test_friendship_update
    #TODO: Write me.
  end

  def test_friendship_state
    get :friendship_state, :"kopal.identity" => 'http://test.host/profile/'
  end
end
