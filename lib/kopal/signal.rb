#Objects, which hold the response or data to be transmitted via Kopal::Antenna
module Kopal::Signal
  include Kopal::KopalHelper

  def headers
    @headers_
  end
end

class Kopal::Signal::Request
  include Kopal::Signal
  attr_accessor :uri, :http_method

  def initialize request_uri
    self.uri = request_uri
    @http_method = 'GET'
    @headers_ = {}
  end

  def uri= value
    @uri = URI.parse(value)
  end
end

class Kopal::Signal::Response
  include Kopal::Signal #makes me.is_a? Kopal::Signal

  attr_reader :response_uri
  attr_reader :response_hash

  #Some kind of Rails deprecation warning for @response and @headers in Netbeans.
  #Response is a Net::HTTPResponse object
  #@param [Net::HTTPResponse, Rack::Response]
  #@param [String, Kopal::Url] url from which the response generated.
  def initialize response, response_uri
    @response_ = response
    @response_uri = response_uri
    @headers_ = case @response_
      when Net::HTTPResponse
        @response_.to_hash
      when Rack::Response
        @response_.headers
      end
    try_extract_key_value_pairs_for_kc
  end

  def response
    @response_
  end

  #Returns whether response is in format defined for Kopal Connect
  #@return boolean
  def kopal_connect?
    !!@response_hash
  end

  def kopal_connect_discovery?
    kopal_connect?() && response_hash.has_key?('kopal.identity') &&
      response_hash.has_key?('kopal.name') && response_hash.has_key?('kopal.public-key')
  end
  
  #Returns true if body is an XML with root element KopalFeed.
  #Raises Kopal::KopalXmlError if required attributes are not present.
  def kopal_feed?
    !!(body_xml? && body_xml.root.name == "KopalFeed" && kopal_revision)
  end
  
  def body_raw
    @response_.body
  end

  def body_xml?
    !body_xml.root.nil?
  end

  #Returns an instance of REXML::Document
  def body_xml
    @body_xml ||= body_xml!
  end

  #Bypass cache
  def body_xml!
    @body_xml = REXML::Document.new(body_raw)
  end

  #returns nil if not present
  #@deprecated Belongs to Kopal::Feed
  def kopal_platform
    begin
     return body_xml.root.attributes['platform']
    rescue => e
      raise Kopal::KopalXmlError, "Not a valid Kopal XML stream."
    end
  end

  #returns Kopal::KopalXmlError if not present
  #@deprecated Belongs to Kopal::Feed
  def kopal_revision
    begin
     raise if body_xml.root.attributes['revision'].blank?
     return body_xml.root.attributes['revision']
    rescue => e
      raise Kopal::KopalXmlError, "Not a valid Kopal XML stream."
    end
  end

private

  def try_extract_key_value_pairs_for_kc
    response_hash = {}
    pairs = body_raw.split("\n")
    pairs.each {|pair|
      v = pair.split(':')
      return if v.size < 2
      k = v.shift.strip
      v = CGI::unescape(v.to_s.strip)
      response_hash[k] = v
    }
    return unless response_hash.has_key? 'kopal.connect'
    @response_hash = response_hash
  end
  
end

