#Extends URI::HTTP with helpful methods.
class Kopal::Url < URI::HTTP

  def initialize uri
    uri = URI.parse uri
    #Kind of kopal_url_object = (Kopal::Url) uri_http_object (From C/C++)
    super *[uri.scheme, uri.userinfo, uri.host, uri.port, uri.registry,
      uri.path, uri.opaque, uri.query, uri.fragment]
    extract_query_hash
  end

  #Keys should be +String+.
  attr_accessor :query_hash
  alias super_query query

  #returns a new object instead of in-place replacement.
  def make_https
    self.dup.make_https!
  end

  #in place.
  def make_https!
    self.scheme = 'https'
    self.port = URI::HTTPS::DEFAULT_PORT
    self
  end

  def query
    build_query_from_hash
  end

  def query= *args
    super *args
    extract_query_hash
  end

  #Need to call after modifying query_hash.
  #LATER: Make this procedure done automatically after modification of query_hash.
  #One method will be adding methods like - <tt>add_queries</tt> <tt>delete_query</tt>
  def build_query
    self.query = build_query_from_hash
  end

  #@return [String] final url after building the query parameters.
  def to_s
    build_query
    super
  end


private

  def extract_query_hash
    @query_hash = {}
    super_query.blank? || super_query.split('&').each { |parameter|
      k,v = parameter.split('=')
      @query_hash[k] = v
    }
  end

  def build_query_from_hash
    #Should escape? or leave to parent class?
    #query_hash.to_a.map{|p| p.join '=' }.join('&')
    #ESCAPE as parent class won't.
    query_hash.to_a.map{|p| p.map{|q| CGI.escape(q.to_s)}.join '=' }.join('&')
  end
  
end