class HomeController < ApplicationController
  def index
  end
  
  def profile_image
    render :nothing => true, :status => 404
  end

end
