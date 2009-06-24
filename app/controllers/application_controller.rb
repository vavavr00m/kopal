# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require 'ostruct'
#KopalHelper in models.
ActiveRecord::Base.send('include', KopalHelper)
#TODO: Place <tt>div#SurfaceLeft</tt> after <tt>div#SurfaceFront</tt> using some
#      negative margin CSS technique in <tt>layout.html.erb</tt>
#TODO: Hook in mercurial to run all test successfully before commit.
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

  def render_kopal_error id_or_message = 0x0000, message_with_id = nil
    case id_or_message
    when Integer
      id = id_or_message
      message = message_with_id || Kopal::KOPAL_ERROR_ID[id]
    else
      message = id_or_message
    end
    xml = Builder::XmlMarkup.new
    xml.instruct!
    xml = xml.Kopal(:revision => Kopal::CONNECT_PROTOCOL_REVISION,
      :platform => Kopal::PLATFORM) { |xm|
      xm.KopalError { |x|
        x.ErrorID sprintf("0x%X", id) if id
        x.ErrorMessage message
      }
    }
    render :xml => xml, :staus => 400
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
    @page.title = @profile_user.feed.name + " &ndash; Kopal Profile"
    @page.description = "Profile for #{Kopal["feed_preferred_calling_name"]}" if
      Kopal["feed_preferred_calling_name"]
    @page.stylesheets = ['home']
    flash.now[:notification] = "You have new friendship requests. <a href=\"" +
      organise_path(:action => 'friend') + "\">View</a>." if
      UserFriend.find_by_friendship_state('pending')
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
