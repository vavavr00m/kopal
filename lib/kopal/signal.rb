#Objects, which hold the response or data to be transmitted via Kopal::Antenna
module Kopal::Signal
  include KopalHelper
  attr_accessor :headers
end

class Kopal::Signal::Request
  include Kopal::Signal
  
  attr_accessor :request_uri, :request_port, :http_method

  def initialize request_uri
    @request_uri = normalise_url(request_uri)
    @http_method = 'GET'
    @request_uri =~ /^https:\/\// ? 
      @request_port = 443 : @request_port = 80
    @headers = {}
  end
  
end

class Kopal::Signal::Response
  include Kopal::Signal #makes me.is_a? Kopal::Signal
  
  attr_reader :response
  
  #Response is a Net::HTTPResponse object
  def initialize response
    @response = response
    @headers = @response.headers
  end
  
  #Returns true if body is an XML with root element Kopal
  def kopal_discovery?
  end
  
  #Returns true if body is an XML with root element KopalFeed.
  #Raises Kopal::KopalXmlError if required attributes are not present.
  def kopal_feed?
  end
  
  def body_raw
    @response.body
  end
  
  def body_xml
  end
  
  def platform
  end
  
  def revision
  end
  
end

