require 'test_helper'

class KopalTest < ActiveSupport::TestCase

  def test_schema_has_loaded_successfully
    assert_equal [], KopalFriend.all
    assert_equal 1, KopalPreference.all.length
    assert_equal 'last_migration_revision', KopalPreference.first.preference_name
  end

  def test_KopalPref_works_good
    KopalPref.testing_is = "going good"
    assert_equal "going good", KopalPreference.find_by_preference_name('testing_is').preference_text
    assert_equal "going good", KopalPref.testing_is
    KopalPref.everything_is_string = 1
    assert_equal "1", KopalPreference.find_by_preference_name('testing_is').preference_text
  end

  def test_a_migration_has_run
    before = KopalPref.last_migration_revision
    #run a dummy migration
    assert_equal before+1, KopalPref.last_migration_revision #won't work, they are dated not numbered.
  end
  
end
