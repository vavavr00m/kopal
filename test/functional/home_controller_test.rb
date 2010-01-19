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

  def test_comment_is_reachable
    get :comment
    assert_response :success
  end

  def test_comment_can_post_new_comment
    post :comment, {}
    assert_response 400
    assert !assigns(:profile_comment).valid?
    assert assigns(:profile_comment).errors[:comment_text]
    assert_equal "can't be blank", assigns(:profile_comment).errors[:comment_text]
    assert assigns(:profile_comment).errors[:name]
    assert_equal "can't be blank", assigns(:profile_comment).errors[:name]

    old_size = Kopal::ProfileComment.find(:all).size
    time = Time.now
    post :comment, {:profile_comment => {:name => "John Doe", 
        :comment_text => "Hello, world! #{time}", :email => 'something@example.org' }}
    new_size = Kopal::ProfileComment.find(:all).size
    assert assigns(:profile_comment).valid?, assigns(:profile_comment).errors.inspect
    assert_equal old_size+1, new_size
    assert_response :redirect
    assert_redirected_to assigns(:kopal_route).profile_comment
    assert_equal "Comment submitted successfully.", flash[:highlight]
    last_row = Kopal::ProfileComment.find(:last)
    assert_equal 'John Doe', last_row.name
    assert_equal "Hello, world! #{time}", last_row.comment_text
  end
end
