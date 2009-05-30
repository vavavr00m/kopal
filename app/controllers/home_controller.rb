class HomeController < ApplicationController

  #TODO: in place editor for "Status message".
  def index
    unless params[:"kopal.talk"].blank?
      params[:controller] = 'discovery'
      redirect_to params
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
    session[:and_return_to] ||= params[:and_return_to] || root_path
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

end
