require File.dirname(__FILE__) + '/../test_helper'

class Kopal::Test::UrlTest < ActiveSupport::TestCase


  def test_extracting_query_to_hash
    url = Kopal::Url.new 'http://example.org/?hello=world&foo=bar'
    assert_equal 'world', url.query_hash['hello']
    assert_equal 'bar', Url.query_hash['foo']

    url = Kopal::Url.new 'http://example.org/?hello%2B=world'
    assert_equal 'world', url.query_hash['hello%2B']
  end

  def test_building_query_from_hash
    url = Kopal::Url.new 'http://example.org/?hello=world&foo=bar'
    url.query_hash['hello//'] = 'world'
    assert_equal 'hello=world&foo=bar&hello//=world', url.query
  end
end