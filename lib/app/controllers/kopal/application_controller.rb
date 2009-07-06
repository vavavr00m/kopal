# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require 'ostruct'
require 'rexml/document' #Host server of its.raining.in is not loading REXML::Document automagically, while local server on my local machine does.
#TODO: Place <tt>div#SurfaceLeft</tt> after <tt>div#SurfaceFront</tt> using some
#      negative margin CSS technique in <tt>layout.html.erb</tt>
#TODO: Hook in mercurial to run all test successfully before commit.
class Kopal::ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  helper Kopal::KopalHelper #in views
  include Kopal::KopalHelper #in controllers
  before_filter :initialise
  layout "kopal_application"

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  def authorise
    redirect_to({:controller => '/home', :action => 'signin', :and_return_to =>
        request.request_uri}) and
      return false unless @signed
    true
  end

  #example usages -
  #render_kopal_error("This is my error message")
  #render_kopal_error(0x1234)
  #render_kopal_error(0x1234, "show this error message instead of default with this error code")
  def render_kopal_error id_or_message = 0x0000, message_with_id = nil
    case id_or_message
    when Integer
      id = id_or_message
      message = message_with_id || Kopal::KOPAL_ERROR_CODE_PROTOTYPE[id]
    else
      message = id_or_message
    end
    xml = Builder::XmlMarkup.new
    xml.instruct!
    xml = xml.Kopal(:revision => Kopal::CONNECT_PROTOCOL_REVISION,
      :platform => Kopal::PLATFORM) { |xm|
      xm.KopalError { |x|
        x.ErrorCode sprintf("0x%X", id) if id
        x.ErrorMessage message
      }
    }
    render :xml => xml, :staus => 400
  end
  
private
  def initialise
    self.prepend_view_path Kopal.root.join('lib', 'app', 'views').to_s
    Kopal::Routing.ugly_hack self.dup
    @@request = request
    Kopal.initialise
    I18n.locale = params[:culture]
    @signed = true if session[:signed]
    @profile_user = Kopal::ProfileUser.new
    @visitor = Kopal::VisitingUser.new
    @page = OpenStruct.new
    #When theme support is implemented, these should go to theme controller.
    @page.title = @profile_user.feed.name + " &ndash; Kopal Profile"
    @page.description = "Profile for #{Kopal["feed_preferred_calling_name"]}" if
      Kopal["feed_preferred_calling_name"]
    @page.stylesheets = ['home']
    flash.now[:notification] = "You have new friendship requests. <a href=\"" +
      organise_path(:action => 'friend') + "\">View</a>." if
      Kopal::UserFriend.find_by_friendship_state('pending')
  end
end
