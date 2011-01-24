require 'test_helper'

class Kopal::KopalPreferenceTest < ActiveSupport::TestCase
  KP = Kopal::KopalPreference

  def setup
    #TODO: Need to reset database schema before every test in test_helper.rb.
    KP.delete_all #alternative for now.
  end
  
  def test_schema_has_loaded
    assert_equal [], KP.all
  end

  def test_preference_name_are_always_lowercase
    a = Kopal::KopalPreference.new
    a.preference_name = "AbCdF"
    a.valid? #Call validation
    assert_equal 'abcdf', a.preference_name
  end

  def test_save_and_get_field_method
    Kopal::KopalPreference.save_field(Kopal::KopalAccount::DEFAULT_PROFILE_ACCOUNT_ID,
      'feed_real_name', 'Example.')
    assert_equal 'Example.', Kopal::KopalPreference.get_field(Kopal::KopalAccount::DEFAULT_PROFILE_ACCOUNT_ID,
      'feed_real_name')
  end

  test "test_only_fields_of_FIELDS_are_allowed" do
    a = Kopal::KopalPreference.new
    a.kopal_account_id = Kopal::KopalAccount::DEFAULT_PROFILE_ACCOUNT_ID
    a.preference_name = 'feed_real_name'
    a.preference_text = "Feed name should be blank."
    assert a.valid?, a.errors.inspect
    a.preference_name = 'this_feed_name_should_not_exist'
    assert !a.valid?
  end

  def test_preference_name_allows_temp_
    a = Kopal::KopalPreference.new
    a.preference_name = 'temp_anything'
    a.valid?
    assert_nil a.errors[:preference_name]
    a.preference_name = 'tempanything'
    assert !nil, a.errors[:preference_name]
  end

  def test_method_preference_name_valid
    assert_equal true, KP.preference_name_valid?('feed_real_name')
    assert_equal false, KP.preference_name_valid?('this_feed_name_should_not_exist')
    assert_equal 'deprecated', KP.preference_name_valid?('example_deprecated_field')
  end
  
end
