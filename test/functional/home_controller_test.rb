require 'test_helper'

class Kopal::HomeControllerTest < ActionController::TestCase
  
  def test_index_is_reachable
    get :index
    assert_response :success
  end

  def test_feed_is_reachable
    get :feed
    assert_response :success
  end

  def test_profile_image_is_reachable
    get :profile_image
    assert_response :redirect #As of now
  end
end
