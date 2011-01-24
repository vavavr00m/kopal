require File.dirname(__FILE__) + '/test_helper.rb'
require 'rails_generator'
require 'rails_generator/scripts/generate'

class MigrationGeneratorTest < Test::Unit::TestCase
  def setup
    @previous_state = ActiveRecord::Base.pluralize_table_names
    ActiveRecord::Base.pluralize_table_names = false
    FileUtils.mkdir_p(fake_rails_root)
    @original_files = file_list
  end

  def teardown
    ActiveRecord::Base.pluralize_table_names = @previous_state
    FileUtils.rm_r(fake_rails_root)
  end

  def test_generates_correct_file_name
    Rails::Generator::Scripts::Generate.new.run(["kopal_migration", "some_name_nobody_is_likely_to_ever_use_in_a_real_migration"],  :destination => fake_rails_root)
    new_file = (file_list - @original_files).first
    assert_match /kopal_plugin_some_name_nobody_is_likely_to_ever_use_in_a_real_migration/, new_file
  end
  
private

  def fake_rails_root
    File.join(File.dirname(__FILE__), 'rails_root')
  end

  def file_list
    Dir.glob(File.join(fake_rails_root, "db", "migrate", "*"))
  end
end
