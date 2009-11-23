require "test_helper"

class Kopal::KopalHelperTest < ActiveSupport::TestCase
  include Kopal::KopalHelper
  
  test "normalise_url is a identity function for normalised url" do
   [
     'http://127.0.0.1/',
     #TODO: Add more.
   ].each { |id|
    assert_equal normalise_url(id), normalise_url(normalise_url(id))
   }
  end
end
