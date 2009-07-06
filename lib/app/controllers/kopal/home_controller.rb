class Kopal::HomeController < Kopal::ApplicationController

  #TODO: in place editor for "Status message".
  def index
    unless params[:"kopal.feed"].blank?
      redirect_to home_path(:action => 'feed')
      return
    end
    unless params[:"kopal.connect"].blank?
      params[:controller] = 'connect'
      params[:action] = params[:"kopal.subject"].to_s.gsub("-", "_")
      redirect_to params
    end
  end

  #Redirects to Visitor's Profile Homepage.
  def foreign
    if request.post?
      r = false
      case params[:subject]
      when 'friendship-request':
        r = render_to_string :inline =>
          '<%= generate_friendship_request_link(normalise_url(params[:identity])) %>'
      end
      redirect_to r if r
    end
  end

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

  def signout
    session[:signed] = false
    redirect_to(params[:and_return_to] || root_path)
  end

  def stylesheet
    render :template => "stylesheet/#{params[:id]}.css", :layout => false
  end

end
