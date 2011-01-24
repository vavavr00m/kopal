require 'test_helper'

class Kopal::OrganiseControllerTest < ActionController::TestCase

  def setup
    get :index
    @kopal_identity = assigns(:profile_user).kopal_identity.to_s
  end

  def test_index_is_not_reachable_without_authentication
    get :index
    #@request.request_uri is '/kopal/organise' in test environment.
    assert_redirected_to assigns(:kopal_route).signin :and_return_to => @request.request_uri
  end

  def test_index_is_reachable
    get :index, {}, {:kopal => {:signed_kopal_identity => @kopal_identity}}
    assert_response :redirect
    assert_redirected_to({:action => 'dashboard'})
  end

  def test_dashboard_is_reachable
    get :dashboard, {}, {:kopal => {:signed_kopal_identity => @kopal_identity}}
    assert_response :redirect
    assert_redirected_to :action => 'edit_identity'
  end

  def test_config_is_reachable_and_works
    session_ = {:kopal => { :signed_kopal_identity => @kopal_identity}}
    get :config, {}, session_
    assert_response :success
    assert_equal "Key can not be empty.", flash[:notice]

    get :config, {:key => 'this_field_is_invalid'}, session_
    assert_equal "Invalid key", flash[:notice][0..10], flash[:notice]

    get :config, {:key => 'example_deprecated_field'}, session_
    assert flash[:notice]["<code>#{assigns(:key)}</code> is deprecated."], flash[:notice]

    post :config, {:key => 'feed_real_name', :value => ''}, session_
    assert_response :success
    assert flash[:notice]["Real name must not be blank"], flash[:notice]

    post :config, {:key => 'Feed_real_name', :value => 'new value via config.'}, session_
    assert_equal :feed_real_name, assigns(:key)
    assert_response :redirect
    assert 'new value via config.', assigns(:profile_user)[:feed_real_name]
    
    get :config, {:key => 'Feed_Real_name'}, session_
    assert assigns(:present_value), flash[:notice]
  end

  def test_edit_identity_is_reachable
    get :edit_identity, {}, {:kopal => { :signed_kopal_identity => @kopal_identity}}
    assert_response :success
  end

  def test_edit_identity_is_working_good
    posting = {
      :feed_real_name => "Test user",
      :feed_aliases => "Hello,\nWorld!",
      :profile_status_message => "Testing",
      :feed_description => "Test description",
      :feed_gender => "Male",
      :feed_birth_time => { '(1i)' => '2000', '(2i)' => '01', '(3i)' => '02'},
      :feed_birth_time_pref => 'ymd',
      :feed_email => 'user@example.org',
      :feed_show_email => 'yes',
      :feed_city => "Bangalore",
      :feed_country_living_code => 'IN'
    }
    dry = Proc.new {
      post :edit_identity, posting, {:kopal => { :signed_kopal_identity => @kopal_identity}}
      assert_response :success
      assert_nil flash[:notice]
      assert_equal "Profile updated!", flash[:highlight]
    }
    dry.call
    assert_equal "Test user", assigns(:profile_user)[:feed_real_name]
    assert_equal "Hello,\nWorld!", assigns(:profile_user)[:feed_aliases]
    assert_equal ["Hello,", "World!"], assigns(:profile_user).feed.aliases
    assert_nil assigns(:profile_user)[:feed_preferred_calling_name]
    assert_equal "Test user", assigns(:profile_user).feed.name
    assert_equal "Testing", assigns(:profile_user)[:profile_status_message]
    assert_equal "Test description", assigns(:profile_user)[:feed_description]
    assert_equal "Male", assigns(:profile_user)[:feed_gender]
    assert_equal DateTime.new(2000,01,02), assigns(:profile_user)[:feed_birth_time]
    assert_equal 'ymd', assigns(:profile_user)[:feed_birth_time_pref]
    assert_equal 'user@example.org', assigns(:profile_user)[:feed_email]
    assert_equal 'yes', assigns(:profile_user)[:feed_show_email]
    assert_equal 'IN BLR', assigns(:profile_user)[:feed_city]
    assert_equal 'yes', assigns(:profile_user)[:feed_city_has_code]
    assert_equal 'IN', assigns(:profile_user)[:feed_country_living_code]
    
    posting.update :feed_preferred_calling_name => "World!"
    dry.call
    assert_equal "World!", assigns(:profile_user)[:feed_preferred_calling_name]
    assert_equal "World!", assigns(:profile_user).feed.name
    
    posting.update :feed_city => "Bangalore2"
    dry.call
    assert_equal "Bangalore2", assigns(:profile_user)[:feed_city]
    assert_equal "no", assigns(:profile_user)[:feed_city_has_code]
  end

  def test_friend
    #TODO: Write me.
  end

  #Just to be sure
  def test_change_password_is_not_reachable_without_authentication
    get :change_password
    assert_redirected_to assigns(:kopal_route).signin :and_return_to => @request.request_uri
  end

  def test_change_password_is_reachable
    get :change_password, {}, {:kopal => { :signed_kopal_identity => @kopal_identity}}
    assert_response :success
  end

  def test_change_password
    require 'digest'
    session_ = {:kopal => {:signed_kopal_identity => @kopal_identity}}
    get :change_password
    Kopal::KopalPreference.save_password assigns(:profile_user).account.id, 'old-password'
    old_salt = assigns(:profile_user)[:account_password_salt]
    old_hash = assigns(:profile_user)[:account_password_hash]
    post :change_password, {}, session_
    assert_equal "Password is blank.", flash[:notice]
    assert_equal old_salt, assigns(:profile_user)[:account_password_salt]
    assert_equal old_hash, assigns(:profile_user)[:account_password_hash]
    post :change_password, {:password => 'a', :password_confirmation => 'b'}, session_
    assert_equal "Passwords do not match.", flash[:notice]
    assert_equal old_salt, assigns(:profile_user)[:account_password_salt]
    assert_equal old_hash, assigns(:profile_user)[:account_password_hash]
    post :change_password, {:password => 'a', :password_confirmation => 'a'}, session_
    assert_equal "Password changed!", flash[:highlight]
    new_salt = assigns(:profile_user)[:account_password_salt]
    assert_not_equal old_salt, new_salt
    assert_equal Digest::SHA512.hexdigest('a' + new_salt), assigns(:profile_user)[:account_password_hash]
    assert_redirected_to assigns(:kopal_route).root
  end
end
