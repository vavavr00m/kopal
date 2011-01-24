require "#{File.dirname(__FILE__)}/../test_helper"

class PathTest < Test::Unit::TestCase

  def test_that_all_paths_exist
    (Kopal::Path.methods - Object.methods).each { |path|
      assert File.exists?(Kopal::Path.send(path)), path.to_s
    }
  end
end