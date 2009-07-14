class Kopal::OpenIDController < Kopal::ApplicationController

  def index
    render :text => 'Service not defined.', :status => 501
  end

  def server
    Kopal::OpenID.server :params => params
  end

  def consumer
    
  end
end
