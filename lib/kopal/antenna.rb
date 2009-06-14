#Reference from ruby-openid library (fetchers.rb).
class Kopal::Antenna
  
  class FetchingError < Kopal::KopalError; end;
  class HTTPTooManyRedirects < FetchingError; end;
  
  USER_AGENT = "kopal/#{Kopal::SOFTWARE_VERSION} (#{RUBY_PLATFORM})"
  
  REDIRECT_LIMIT = 5
  TIMEOUT = 60
  
  #Signal is a Kopal::Signal::Request
  #Returns a Kopal::Signal::Response
  #TODO: Support HTTPS
  def self.broadcast signal #or receive?
    raise ArgumentError, "Expected an object of Kopal::Signal::Request but is " +
      signal.class.to_s unless signal.is_a? Kopal::Signal::Request
    signal.headers['User-agent'] ||= USER_AGENT
    transmit signal, 0
  end

private
  
  def self.transmit signal, redirects_total
    begin
      connection = Net::HTTP.new(signal.uri.host, signal.uri.port)
      connection.read_timeout =
        connection.open_timeout = TIMEOUT
      response = connection.start { 
        connection.request_get(signal.uri.request_uri, signal.headers)
      }
      case response
      when Net::HTTPRedirection
        raise HTTPTooManyRedirects, "Too many redirects, not fetching " + 
          response['location'] + '. Redirect limit is ' + 
          REDIRECT_LIMIT.to_s if redirects_total >= REDIRECT_LIMIT
        signal.uri = response['location']
        transmit signal, redirects_total.next
      else
        return Kopal::Signal::Response.new(response, signal.uri.to_s)
      end
    rescue => e
      raise FetchingError, "Exception #{e.class} raised while fetching " +
        signal.uri.request_uri + ". Message recieved - \n" + e.message
    end
  end
end

Kopal::Aerial = Kopal::Antenna

