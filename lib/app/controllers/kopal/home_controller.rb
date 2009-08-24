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
    @comments = Kopal::ProfileComment.find(:all, :order => 'created_at DESC', :limit => 20)
  end

  #Shoutbox
  def comment
    @_page.title <<= "Shoutbox"
    if request.post?
      @profile_comment = Kopal::ProfileComment.new params[:profile_comment]
      if @visitor.known?
        @profile_comment.is_kopal_identity = true
        @profile_comment.website_address = @visitor.kopal_identity.to_s
      end
      #Run validations before running verify_recaptcha(), since running validations
      #will reset the error strings of model and errors set by verify_recaptcha() will be lost.
      is_valid = @profile_comment.valid?
      human_verified = true
      human_verified = false unless
        verify_recaptcha(:model => @profile_comment) if can_use_recaptcha?
      if is_valid and human_verified
        @profile_comment.save!
        flash[:highlight] = "Comment submitted successfully."
        redirect_to Kopal.route.profile_comment
      end
    end
    @comments = Kopal::ProfileComment.paginate(:page => params[:page], :order => 'created_at DESC')
  end

  def friend
    @_page.title <<= 'Friends'
  end

  #Redirects to Visitor's Profile Homepage.
  def foreign
    @_page.title <<= "Foreign Affairs"
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
      redirect_to gravatar_url Kopal['feed_email']
    else
      #redirect to url or send raw data
      redirect_to Kopal::Identity.new(params[:of]).profile_image_url
    end
  end

  #Sign-in page for user.
  def signin
    @_page.title <<= "Sign In"
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
    render :template => "siterelated/#{params[:id]}.#{params[:format]}", :layout => false
  end
  alias javascript stylesheet

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
