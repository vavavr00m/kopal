class HomeController < ApplicationController
  def index
  end
  
  def profile_image
    render :nothing => true, :status => 404
  end

  def signin
    session[:and_return_to] ||= params[:and_return_to] || root_path
    if request.post?
      if params[:password] == Kopal.config(:account_password)
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
