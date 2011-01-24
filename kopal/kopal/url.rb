#Extends URI::HTTP with helpful methods.
class Kopal::Url < URI::HTTP

  def initialize uri
    uri = URI.parse uri
    #Kind of kopal_url_object = (Kopal::Url) uri_http_object (From C/C++)
    super *[uri.scheme, uri.userinfo, uri.host, uri.port, uri.registry,
      uri.path, uri.opaque, uri.query, uri.fragment]
    @query_hash = {}
    extract_query_hash
  end

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

  #No escaping is done. Same behaviour as super. (Will also result in double escaping).
  def query= *args
    super *args
    extract_query_hash
  end

  #@return [String] Returns new URL
  def update_parameters hash
    hash.each {|k,v|
      @query_hash[CGI.escape(k.to_s)] = CGI.escape(v.to_s)
    }
    to_s
  end

  #If passed no arguments, will delete all parameters
  #@return [String] returns new URL
  def delete_parameters *args
    return @build_query = {} if args.size.zero?
    args.each {|a|
      @build_query.delete a.to_s
    }
    to_s
  end

  #@return [String] final url after building the query parameters.
  def to_s
    build_query
    super
  end


private

  def extract_query_hash
    @query_hash = {}
    query.blank? || query.split('&').each { |parameter|
      k,v = parameter.split('=')
      @query_hash[k] = v
    }
  end

  def build_query
    self.query = build_query_from_hash
  end

  def build_query_from_hash
    #Should escape? or leave to parent class?
    @query_hash.to_a.map{|p| p.join '=' }.join('&') #Escaping happens in calling methods.
    #ESCAPE as parent class won't.
    #query_hash.to_a.map{|p| p.map{|q| CGI.escape(q.to_s)}.join '=' }.join('&')
  end
  
end