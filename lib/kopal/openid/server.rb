#Based on example in Gem 'ruby-openid'
class Kopal::OpenID::Server
  include ::OpenID::Server

  def initialize hash = {}
    params = hash[:params]
    begin
      openid_request = server.decode_request(params)
    rescue ProtocolError => e
      raise Kopal::OpenIDError, e
    end

    unless openid_request
      raise Kopal::OpenIDError, "This is an OpenID server endpoint." #This situation is exceptionable?
    end

    openid_response = nil

    if openid_request.kind_of? CheckIDRequest
      
      if openid_request.id_select
        if openid_request.immediate
          openid_response = openid_request.answer false
        elsif hash[:signed].nil?
          raise AuthenticationRequired
        end
      end

      if openid_response
        nil
      elsif openid_request.immediate
        openid_response = openid_request.answer false, Kopal.route.openid_server
      else #Always authorised for now.
        openid_response = openid_request.answer true, nil, Kopal.identity
      end
    else
      openid_response = server.handle_request(openid_request)
    end
    return openid_response
  end

  #TODO: Change to session or database.
  def store
    if @store.nil?
      dir = Pathname.new(RAILS_ROOT).join('db').join('openid-store')
      @store = OpenID::Store::Filesystem.new(dir)
    end
  end

private
  def server
    @server ||= Server.new(store, Kopal.identity)
  end
end