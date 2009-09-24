require 'test_helper'

class Kopal::OrganiseControllerTest < ActionController::TestCase

  def test_index_is_not_reachable_without_authentication
    get :index
    #@request.request_uri is '/kopal/organise' in test environment.
    assert_redirected_to Kopal.route.signin :and_return_to => @request.request_uri
  end

  def test_index_is_reachable
    get :index, {}, {:signed => true}
    assert_response :redirect
    assert_redirected_to :action => 'dashboard'
  end

  def test_dashboard_is_reachable
    get :dashboard, {}, {:signed => true}
    assert_response :redirect
    assert_redirected_to :action => 'edit_profile'
  end

  def test_config_is_reachable_and_works
    get :config, {}, {:signed => true}
    assert_response :success
    assert_equal "Key can not be empty.", flash[:notice]

    get :config, {:key => 'this_field_is_invalid'}, {:signed => true}
    assert_equal "Invalid key", flash[:notice][0..10], flash[:notice]

    get :config, {:key => 'example_deprecated_field'}, {:signed => true}
    assert flash[:notice]["<code>#{assigns(:key)}</code> is deprecated."], flash[:notice]

    post :config, {:key => 'feed_real_name', :value => ''}, {:signed => true}
    assert_response :success
    assert flash[:notice]["Real name must not be blank"], flash[:notice]

    post :config, {:key => 'Feed_real_name', :value => 'new value via config.'}, {:signed => true}
    assert_equal :feed_real_name, assigns(:key)
    assert_response :redirect
    assert 'new value via config.', Kopal[:feed_real_name]
    
    get :config, {:key => 'Feed_Real_name'}, {:signed => true}
    assert assigns(:present_value), flash[:notice]
  end

  def test_edit_identity_is_reachable
    get :edit_identity, {}, {:signed => true}
    assert_response :success
  end

  def test_edit_identity_is_working_good
    posting = {
      :feed_real_name => "Test user",
      :feed_aliases => "Hello,\nWorld!",
      :user_status_message => "Testing",
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
      post :edit_identity, posting, {:signed => true}
      assert_response :success
      assert_nil flash[:notice]
      assert_equal "Profile updated!", flash[:highlight]
    }
    dry.call
    assert_equal "Test user", Kopal[:feed_real_name]
    assert_equal "Hello,\nWorld!", Kopal[:feed_aliases]
    assert_equal ["Hello,", "World!"], Kopal::ProfileUser.new.feed.aliases
    assert_nil Kopal[:feed_preferred_calling_name]
    assert_equal "Test user", Kopal::ProfileUser.new.feed.name
    assert_equal "Testing", Kopal[:user_status_message]
    assert_equal "Test description", Kopal[:feed_description]
    assert_equal "Male", Kopal[:feed_gender]
    assert_equal DateTime.new(2000,01,02), Kopal[:feed_birth_time]
    assert_equal 'ymd', Kopal[:feed_birth_time_pref]
    assert_equal 'user@example.org', Kopal[:feed_email]
    assert_equal 'yes', Kopal[:feed_show_email]
    assert_equal 'IN BLR', Kopal[:feed_city]
    assert_equal 'yes', Kopal[:feed_city_has_code]
    assert_equal 'IN', Kopal[:feed_country_living_code]
    
    posting.update :feed_preferred_calling_name => "World!"
    dry.call
    assert_equal "World!", Kopal[:feed_preferred_calling_name]
    assert_equal "World!", Kopal::ProfileUser.new.feed.name
    
    posting.update :feed_city => "Bangalore2"
    dry.call
    assert_equal "Bangalore2", Kopal[:feed_city]
    assert_equal "no", Kopal[:feed_city_has_code]
  end

  def test_friend
    #TODO: Write me.
  end

  #Just to be sure
  def test_change_password_is_not_reachable_without_authentication
    get :change_password
    assert_redirected_to Kopal.route.signin :and_return_to => @request.request_uri
  end

  def test_change_password_is_reachable
    get :change_password, {}, {:signed => true}
    assert_response :success
  end

  def test_change_password
    Kopal[:account_password] = 'old-password'
    post :change_password, {}, {:signed => true}
    assert_equal "Password is blank.", flash[:notice]
    assert_equal 'old-password', Kopal[:account_password]
    post :change_password, {:password => 'a', :password_confirmation => 'b'}, {:signed => true}
    assert_equal "Passwords do not match.", flash[:notice]
    Kopal.reload_variables!
    assert_equal 'old-password', Kopal[:account_password]
    post :change_password, {:password => 'a', :password_confirmation => 'a'}, {:signed => true}
    assert_equal "Password changed!", flash[:highlight]
    assert_equal 'a', Kopal[:account_password]
    assert_redirected_to Kopal.route.root
  end
end
