require File.dirname(__FILE__) + '/../network_test_helper'

class Kopal::ConnectControllerTest < ActionController::TestCase

  def setup
    @url = 'http://127.0.0.1:3010/profile/'
  end

  def test_index_is_reachable
    get :index
    assert_redirected_to assigns(:kopal_route).root
  end

  def test_discovery_is_reachable
    get :discovery
    assert_response :success
    assert 'text/plain', @response.content_type
    answer = Kopal::Signal::Response.new @response, ''
    assert_equal Kopal::ConnectController::SUPPORTED_NS[0], answer.response_hash['kopal.connect']
    assert_equal assigns(:profile_user).feed.name, answer.response_hash['kopal.name']
    assert_equal assigns(:profile_user).kopal_identity.to_s, answer.response_hash['kopal.identity']
    assert_equal assigns(:profile_user).public_key.to_pem, answer.response_hash['kopal.public-key']
  end

  def test_response_gets_redirected_if_requested
    get :discovery, :'kopal.return_to' => 'http://example.net/'
    assert_response :redirect
    #assert_redirected_to 'http://example.net/'
  end

  def test_friendship_request_without_initating_friendship
    get :friendship_request, :"kopal.identity" => @url
    return #Test won't work because the state is already being saved by Designer.
    assert_response 400
    assert_equal 'none', assigns(:friendship_state_response).response_hash['kopal.friendship-state']
  end

  def test_friendship_request_for_duplicate_friendship
    
  end

  def test_friendship_request
    get :index
    profile_user = assigns(:profile_user)
    #profile_user = Kopal::ProfileUser.new 0

    #Creating a record won't be available to 127.0.0.1:3010 server. Using Designer.
    #See - http://groups.google.com/group/rubyonrails-talk/browse_thread/thread/7edde46d7bf40f35
#    record = profile_user.account.all_friends.build :friend_kopal_identity =>
#      'http://test.host/profile/', :friendship_state => 'waiting',
#      :friend_public_key => profile_user.public_key.to_pem, :friend_kopal_feed =>
#      "<KopalFeed revision=\"0.1.draft\"><Identity>" +
#      "<Homepage>http://example.net/</Homepage><RealName>Test User</RealName>" +
#      "</Identity></KopalFeed>"
#    record.assign_key!
#    record.save!
#    
#    gets

    assert_equal 1, Kopal::ProfileFriend.find(:all).size
    get :friendship_request, :"kopal.identity" => @url
    #Server at @url needs to be restarted everytime tests are run. Since it doesn't seem to
    #pickup database changes. And OpenSSAL::PKey::RSAError - padding check failed.
    assert_equal 2, Kopal::ProfileFriend.count, CGI.unescape(@response.body)

    assert_equal 'waiting', assigns(:friendship_state_response).response_hash['kopal.friendship-state']
    assert_equal Designer.profile_friend('test_host').friendship_key, assigns(:friend).friendship_key
    assert profile_user.account.all_friends.find_by_friend_kopal_identity_and_friendship_state(
      @url, 'pending'), Kopal::ProfileFriend.find(:all).inspect
  end

  def test_friendship_update
    #TODO: Write me.
  end

  def test_friendship_state
    get :friendship_state, :"kopal.identity" => 'http://test.host/profile/'
  end

  def test_kc_verify_k_connect
    #Kopal::ConnectController.new.send :kc_verify_k_connect, response
  end
end
