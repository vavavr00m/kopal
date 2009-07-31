class Kopal::HomeController < Kopal::ApplicationController

  #Homepage. Displayes User's profile and comments.
  #Also redirects to Kopal::ConnectController or feed if requested.
  #TODO: in place editor for "Status message".
  def index
    unless params[:"kopal.feed"].blank?
      redirect_to Kopal.route.feed
      return
    end
    unless params[:"kopal.connect"].blank?
      render_kopal_error "GET parameter \"kopal.subject\" is blank." and return if
        params[:"kopal.subject"].blank?
      params[:action] = params[:"kopal.subject"].to_s.gsub("-", "_")
      params.delete :controller
      params.delete :"kopal.connect"
      params.delete :"kopal.subject"
      #Kopal.route.connect(params) won't work. Got to change string keys to symbols.
      redirect_to Kopal.route.connect Hash[*(params.map { |k,v| [k.to_sym, v] }.flatten)]
    end
  end

  #Shoutbox
  def comment
    
  end

  #Redirects to Visitor's Profile Homepage.
  def foreign
    if request.post?
      identity = Kopal::Identity.new(params[:identity])
      case params[:subject]
      when 'friendship-request'
        redirect_to identity.friendship_request_url
        return
      end
    end
  end

  #Displayes the Kopal Feed for user.
  def feed
    render :layout => false
  end
  
  #Provide more than just Gravatar, including any picture over internet, or 
  #let user upload one if supported gems, RMagick for example are installed.
  def profile_image
    require 'md5'
    if params[:of].blank? #self
      hash = MD5::md5(Kopal['feed_email'])
      redirect_to "http://www.gravatar.com/avatar/#{hash}.jpeg?s=120"
    else
      #redirect to url or send raw data
      redirect_to "http://www.gravatar.com/avatar/a.jpeg?s=120" #testing
    end
  end

  #Sign-in page for user.
  def signin
    session[:and_return_to] ||= params[:and_return_to] || Kopal.route.root
    if request.post?
      if Kopal.authenticate_simple(params[:password])
        session[:signed] = true
        redirect_to( session[:and_return_to])
        session.delete :and_return_to
        return
      end
      flash.now[:notice] = "Wrong password."
    end
  end

  #Signs out user. To sign-out a user, use - +Kopal.route.signout+
  def signout
    session[:signed] = false
    redirect_to(params[:and_return_to] || Kopal.route.root)
  end

  def stylesheet
    render :template => "stylesheet/#{params[:id]}.css", :layout => false
  end

  #Displayes the XRDS file for user. Accessible from +Kopal.route.xrds+
  def xrds
    render 'xrds', :content_type => 'application/xrds+xml', :layout => false
  end

  #Authenticates a user's by her OpenID.
  #
  #Usage -
  #  Kopal.route.openid(:openid_identifier => 'http://www.example.net/')
  #
  def openid
    authenticate_with_openid { |result|
      if result.successful?
        render :text => 'success'
      else
        render :text => 'failed. ' + result.message
      end
    }
  end

  #OpenID server for user's OpenID Identifier.
  def openid_server
    hash = {:signed => @signed, :openid_request => session.delete(:openid_last_request),
      :params => params.dup
    }
    begin
      s = Kopal::OpenID::Server.new hash
      s.begin
      case s.web_response.code
      when 200 #OpenID::Server::HTTP_OK
        render :text => s.web_response.body, :status => 200
      when 302 #OpenID::Server::HTTP_REDIRECT
        redirect_to s.web_response.headers['location']
      else #OpenID::Server::HTTP_ERROR => 400
        render :test => s.web_response.body, :status => 400
      end
    rescue Kopal::OpenID::AuthenticationRequired
      session[:openid_last_request] = s.openid_request
      redirect_to Kopal.route.signin :and_return_to =>
        (Kopal.route.openid_server :only_path => true)
    rescue Kopal::OpenID::OpenIDError => e
      render :text => e.message, :status => 500
    end
  end

end
