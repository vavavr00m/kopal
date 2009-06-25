require 'test_helper'

class KopalPreferenceTest < ActiveSupport::TestCase
  
  def test_schema_has_loaded
    assert_equal [], KopalPreference.all
  end

  def test_preference_name_are_always_lowercase
    a = KopalPreference.new
    a.preference_name = "AbCdF"
    a.valid? #Call validation
    assert_equal 'abcdf', a.preference_name
  end

  def test_save_and_get_field_method
    KopalPreference.save_field('feed_name', 'Example.')
    assert_equal 'Example.', KopalPreference.get_field('feed_name')
  end

  test "test_only_fields_of_FIELDS_are_allowed" do
    a = KopalPreference.new
    a.preference_name = 'feed_name'
    a.preference_text = "Feed name should be blank."
    assert a.valid?
    a.preference_name = 'this_feed_name_should_not_exist'
    assert !a.valid?
  end
  
end
