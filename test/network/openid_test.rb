require File.dirname(__FILE__) + '/../network_test_helper'

class Kopal::OpenidTest < Kopal::NetworkTestHelper

  def test_authentication_with_openid
    #@request.host = 'a.kopal.test'
    identifier = "http://b.kopal.test:#{server_port}/profile/"
    puts "Openid to #{identifier}"
    #Can't get to work.
    #Maybe we need to send the request through server, and listen through it.
    #since b.kopal.test might make a request back to it.
    #get "/profile/home/openid/", {:openid_identifier => identifier}
    #assert_response :redirect, response.body

    #follow_redirect!
  end

  def test_openid_server
    
  end
end