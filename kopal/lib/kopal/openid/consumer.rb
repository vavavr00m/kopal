#Based on example from Gem 'ruby-openid' and OpenIDAuthentication plugin.
class Kopal::OpenID::Consumer

  #Based on OpenIDAuthentication plugin.
  class Result

    attr_accessor :status, :identifier
    
    ERROR_MESSAGES = {
      :missing      => "Can not find OpenID server.",
      :invalid      => "Invalid OpenID.",
      :cancel     => "OpenID verification was canceled.",
      :failure       => "OpenID verification failed.",
      :setup_needed => "OpenID verification needs setup.",
    }

    SUCCESS_STATES = [:successful]

    ERROR_MESSAGES.keys.concat(SUCCESS_STATES).each {|m|
      define_method("#{m}?") {@status == m}
    }

    def initialize code, identifier
      @status = code.to_sym
      @identifier = identifier
    end

    def unsuccessful?
      ERROR_MESSAGES.keys.include? @status
    end

    def message
      ERROR_MESSAGES[@status].to_s
    end

  end
  
class << self
  def begin params, session
   begin
    @session = session
    params[:openid_identifier] =
      Kopal::OpenID.normalise_identifier params[:openid_identifier]
    @openid_request = consumer.begin params[:openid_identifier]
    @openid_request.return_to_args['openid_complete'] = '1'
    rescue Kopal::OpenID::OpenIDInvalid
      yield @error = Result.new(:invalid, params[:openid_identifier])
    rescue ::OpenID::OpenIDError
      yield @error = Result.new(:missing, params[:openid_identifier])
    end
    return self
  end

  def error?
    !!@error
  end

  def openid_request
    @openid_request
  end

  def complete params, request, session
    @session = session
    parameters = params.reject{|k,v|request.path_parameters[k]}
    @openid_response = consumer.complete(parameters, session[:openid_return_url])
    case @openid_response.status
    when OpenID::Consumer::SUCCESS
      yield Result.new(:successful, @openid_response.display_identifier)
    when OpenID::Consumer::CANCEL
      yield Result.new(:cancel, @openid_response.display_identifier)
    when OpenID::Consumer::FAILURE
      yield Result.new(:failure, @openid_response.display_identifier)
    when OpenID::Consumer::SETUP_NEEDED
      yield Result.new(:setup_needed, @openid_response.setup_url)
    end
  end

  #TODO: Change to session or database.
  def store
    if @store.nil?
      dir = Pathname.new(Rails.root).join('tmp').join('kopal-oidc')
      @store = OpenID::Store::Filesystem.new(dir)
    end
  end

private

  def consumer
    @consumer ||= OpenID::Consumer.new(@session, store)
  end
end
end