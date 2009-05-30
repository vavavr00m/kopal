# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require 'ostruct'
#TODO: Place <tt>div#SurfaceLeft</tt> after <tt>div#SurfaceFront</tt> using some
#      negative margin CSS technique in <tt>layout.html.erb</tt>
class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  helper KopalHelper #in views
  include KopalHelper #in controllers
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

  #Get ActionController::Request object in lib/
  #good thing?
  def self.request
    @@request
  end
  
private
  def initialise
    @@request = request
    kopal_config
    I18n.locale = params[:culture]
    @signed = true if session[:signed]
    @profile_user = ProfileUser.new
    @visitor = VisitingUser.new
    @page = OpenStruct.new
    #When theme support is implemented, these should go to theme controller.
    @page.title = @profile_user.name + " &ndash; Kopal Profile"
    @page.description = "Profile for #{Kopal["feed_preferred_calling_name"]}" if
      Kopal["feed_preferred_calling_name"]
    @page.stylesheets = ['home']
  end
  
  #How to get these settings in <tt>environment.rb</tt>?
  #Maybe <tt>Kopal.config</tt> or <tt>config.kopal</tt>?
  #If I write <tt>Kopal.config.account_password</tt> in
  #<tt>Rails::Initializer.run</tt> block, it reports missing constant <tt>Kopal</tt>
  #and if I write it after <tt>Rails::Initializer.run</tt> block, it is read only
  #for the first request after server start.
  #If I write it in <tt>config/kopal.rb</tt>, and <tt>require</tt> it, it gets
  #required only once for the first request.
  #The only method could be is to create it as <tt>config/kopal.yml</tt>.
  #Or should we push every configuration to database?
  def kopal_config
    Kopal.initialise
    Kopal.config.account_password = 'secret01'
  end
end
