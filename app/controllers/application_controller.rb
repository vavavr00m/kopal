# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require 'ostruct'
class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  before_filter :initialise

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  def signed_user?
    @signed
  end

  def authorise
    redirect_to({:controller => '/home', :action => 'signin'}) and
      return false unless signed_user?
    true
  end
  
private
  def initialise
    I18n.locale = params[:culture]
    @signed = true if session[:signed]
    @page = OpenStruct.new
    #When theme support is implemented, these should go to theme controller.
    @page.title = "Kopal Profile"
    @page.description = "Profile for #{KopalPref.feed_preferred_calling_name}" if
      KopalPref.feed_preferred_calling_name
    @page.stylesheets = ['home']
  end
end
