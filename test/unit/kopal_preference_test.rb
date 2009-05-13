require 'test_helper'

class KopalPreferenceTest < ActiveSupport::TestCase
  
  def test_schema_has_loaded
    assert_equal [], KopalPreference.all
  end
  
end
