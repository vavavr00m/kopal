class Kopal::HomeController < Kopal::ApplicationController

  #Homepage. Displayes User's profile and comments.
  #Also redirects to Kopal::ConnectController or feed if requested.
  #TODO: in place editor for "Status message".
  def index
    unless params[:"kopal.feed"].blank?
      redirect_to @kopal_route.feed
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
      redirect_to @kopal_route.connect Hash[*(params.map { |k,v| [k.to_sym, v] }.flatten)]
    end
    @comments = Kopal::ProfileComment.find(:all, :order => 'created_at DESC', :limit => 20)
#    @pages_as_cloud = Kopal::ProfilePage.find(:all).map {|p|
#      { :label => p.to_s, :link => Kopal.route.page(p.page_name),
#        :title => "\"#{p}\", profile pages of #{@profile_user}",
#        :weight => p.page_text[:element].size
#      }
#    }
  end

  #Shoutbox
  def comment
    @_page.title <<= "Shoutbox"
    @comments = Kopal::ProfileComment.paginate(:page => params[:page], :order => 'created_at DESC')
    if request.post?
      @profile_comment = @profile_user.account.comments.build params[:profile_comment]
      @profile_comment.kopal_account_id = @profile_user.account.id
      if @visiting_user.signed?
        @profile_comment.is_kopal_identity = true
        @profile_comment.website_address = @visiting_user.kopal_identity.to_s
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
        redirect_to @kopal_route.profile_comment
        return
      end
      render :comment, :status => 400
    end
  end

  def friend
    @_page.title <<= 'Friends'
  end

  #Redirects to Visitor's Profile Homepage.
  def foreign
    @_page.title <<= "Foreign Affairs"
    params[:returnurl].blank? || session[:kopal][:returnurl] = params[:returnurl]
    if request.post?
      identity = Kopal::Identity.new(params[:identity])
      case params[:subject]
      when 'friendship-request'
        redirect_to identity.friendship_request_url
        return
      when 'signin'
        redirect_to identity.signin_request_url session[:kopal].delete :returnurl
      else
        flash.now[:notice] = "Unidentified value for <code>subject</code>"
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
      redirect_to gravatar_url @profile_user['feed_email']
    else
      #redirect to url or send raw data
      redirect_to Kopal::Identity.new(params[:of]).profile_image_url
    end
  end

  #Sign-in page for profile user.
  def signin
    session[:kopal][:return_after_signin] ||= params[:and_return_to] || @kopal_route.root(:only_path => false)
    params[:via_kopal_connect].blank? || session[:kopal][:signing_via_kopal_connect] = params[:via_kopal_connect]
    @_page.title <<= "Sign In"

    if Kopal.delegate_signin_to_application?
      result = kopal_profile_signin
      return unless result
      session[:kopal][:signed_kopal_identity] = @profile_user.kopal_identity.to_s
      redirect_to session[:kopal].delete :return_after_signin
      return
    else
      if request.post?
        case @profile_user[:authentication_method]
        when 'simple':
          if Kopal::KopalPreference.verify_password(@profile_user.account.id, params[:password])
            session[:kopal][:signed_kopal_identity] = @profile_user.kopal_identity.to_s
            if session[:kopal].delete :signing_via_kopal_connect
              uri = Kopal::Url.new session[:kopal].delete :return_after_signin
              uri.query_hash.update :"kopal.visitor" => @profile_user.kopal_identity.escaped_uri
              uri.build_query
              redirect_to uri.to_s
              return
            end
            redirect_to session[:kopal].delete :return_after_signin
            return
          end
        end
        flash.now[:notice] = "Wrong password."
      end
    end
  end

  def signin_for_visitor
    if params[:openid_identifier].blank?
      redirect_to @kopal_route.home(:action => 'foreign', :subject => 'signin-request')
      return
    end
    authenticate_with_openid { |result|
      if result.successful?
        session[:kopal][:signed_kopal_identity] = result.identifier
      else
        flash[:notice] = "OpenID verification failed for #{params[:openid_identifier]}"
      end
    }
    redirect_to(params[:return_path] || @kopal_route.root) unless send :'performed?'
  end

  #Signs out user. To sign-out a user, use - +Kopal.route.signout+
  def signout
    session[:kopal][:signed_kopal_identity] = false
    redirect_to(params[:and_return_to] || @kopal_route.root)
  end

  #ajax-spinner.gif. Credit - http://www.ajaxload.info/
  def stylesheet
    params[:format] ||= 'css'
    params[:format] = "#{params[:format]}.erb" if params[:id] == 'dynamic'
    render :template => "siterelated/#{params[:id]}.#{params[:format]}", :layout => false
  end
  alias image stylesheet

  def javascript
    params[:format] ||= 'js'
    stylesheet
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
        redirect_to
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

  def update_status_message_aj
    #TODO: Write me.
  end

end
