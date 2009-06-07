#Objects, which hold the response or data to be transmitted via Kopal::Antenna
module Kopal::Signal
  include KopalHelper

  def headers
    @headers_
  end
end

class Kopal::Signal::Request
  include Kopal::Signal
  attr_accessor :uri, :http_method

  def initialize request_uri
    @uri = URI.parse(normalise_url(request_uri))
    @http_method = 'GET'
    @headers_ = {}
  end
end

class Kopal::Signal::Response
  include Kopal::Signal #makes me.is_a? Kopal::Signal

  #Some kind of Rails deprecation warning for @response and @headers
  #Response is a Net::HTTPResponse object
  def initialize response
    @response_ = response
    @headers_ = @response_.to_hash
  end

  def response
    @response_
  end
  
  #Returns true if body is an XML with root element Kopal
  def kopal_discovery?
  end
  
  #Returns true if body is an XML with root element KopalFeed.
  #Raises Kopal::KopalXmlError if required attributes are not present.
  def kopal_feed?
  end
  
  def body_raw
    @response_.body
  end
  
  def body_xml
  end
  
  def platform
  end
  
  def revision
  end
  
end

