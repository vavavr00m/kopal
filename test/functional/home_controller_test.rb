require 'test_helper'

class Kopal::HomeControllerTest < ActionController::TestCase
  
  def test_index_is_reachable
    get :index
    assert_response :success
  end

  def test_index_redirects_to_kopal_feed
    get :index, :"kopal.feed" => true
    assert_response :redirect
    assert_redirected_to assigns(:kopal_route).feed
  end

  def test_index_redirects_to_kopal_connect
    get :index, :"kopal.connect" => true, :"kopal.subject" => 'requested-subject'
    assert_response :redirect
    assert_redirected_to assigns(:kopal_route).kopal_connect(:action => 'requested_subject')
  end

  def test_foreign_is_reachable
    get :foreign
    assert_response :success
  end

  def test_foreign_friendship_request_redirection
    post :foreign, :identity => 'http://friend.example/',
      :subject => "friendship-request"
    assert_response :redirect
    assert_redirected_to Kopal::Identity.new('http://friend.example/').friendship_request_url
  end

  def test_feed_is_reachable
    get :feed
    assert_response :success
  end

  def test_profile_image_is_reachable
    get :profile_image
    assert_response :redirect #As of now
  end

  def test_signin_is_reachable
    get :signin
    assert_response :success
  end

  def test_signing_in
    get :index
    Kopal::KopalPreference.save_password assigns(:profile_user).account.id, 'test-password'
    assert 'simple', assigns(:profile_user)[:authentication_method] #for now
    post :signin, :password => 'wrong-password'
    assert_nil session[:kopal][:signed_kopal_identity]
    post :signin, :password => 'test-password'
    assert session[:kopal][:signed_kopal_identity]
  end

  def test_signout_is_reachable
    get :signout
    assert_response :redirect
    assert_redirected_to assigns(:kopal_route).root
    assert !session[:signed] #nil or false
  end

  def test_stylesheet_is_reachable
    get :stylesheet, :id => 'home'
    assert_response :success
  end

  def test_stylesheet_is_working_good
    get :stylesheet, :id => 'home'
    assert_template 'siterelated/home.css'
  end
end
