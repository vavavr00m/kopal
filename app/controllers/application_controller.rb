# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require 'ostruct'
#TODO: Place <tt>div#SurfaceLeft</tt> after <tt>div#SurfaceFront</tt> using some
#      negative margin CSS technique in <tt>layout.html.erb</tt>
class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  include ApplicationHelper #Helper methods in controller too.
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  before_filter :initialise

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  def authorise
    redirect_to({:controller => '/home', :action => 'signin', :and_return_to =>
        request.request_uri}) and
      return false unless @signed
    true
  end
  
private
  def initialise
    Kopal.initialise
    I18n.locale = params[:culture]
    @signed = true if session[:signed]
    @profile_user = ProfileUser.new
    @page = OpenStruct.new
    #When theme support is implemented, these should go to theme controller.
    @page.title = @profile_user.name + " &ndash; Kopal Profile"
    @page.description = "Profile for #{Kopal["feed_preferred_calling_name"]}" if
      Kopal["feed_preferred_calling_name"]
    @page.stylesheets = ['home']
  end
end
