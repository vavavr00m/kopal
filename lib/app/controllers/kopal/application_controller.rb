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
  include Kopal::OpenID::ControllerHelper
  before_filter :initialise
  layout "kopal_application"

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  #FIXME: Save from Replay attack. a session[:last_signin] timestamp may work.
  #Which expires say, after 2 days. (But session cookies only stay as long as session)?
  #
  #(Second thought) - Authorisation sounds like upgrading someones privileges, while
  #authentication sounds like the process of verifying. Rename this to authenticate?
  #Ex: You are now authorised to do this task.
  #Ex: Please authenticate yourself before continuing.
  def authorise
    #:status => 401 (Unauthorised)
    redirect_to(Kopal.route.signin(:and_return_to => request.request_uri)) and
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
    @signed = true if session[:signed] #DEPRECATED: Use @profile_user.signed? instead.
    @profile_user = Kopal.profile_user session[:signed]
    @visitor = Kopal.visiting_user
    @_page = Kopal::PageView.new
    set_response_headers
    set_page_variables
    actions_for_profile_user if @profile_user.signed?
  end

  def set_response_headers
    response.headers['X-XRDS-Location'] = Kopal.route.xrds
  end

  def set_page_variables
    #When theme support is implemented, these should go to theme controller.
    @_page.add_stylesheet 'home'
  end

  def actions_for_profile_user
    unless Kopal[:meta_upgrade_last_check] and
        Kopal[:meta_upgrade_last_check] > 7.days.ago
      flash.now[:notification] = "New release may be available. \n" +
        "Please run <em>rake kopal:upgrade</em> to check and upgrade."
    end
    if Kopal::UserFriend.find_by_friendship_state('pending')
      flash.now[:notification] = "You have new friendship requests. <a href=\"" +
        organise_path(:action => 'friend') + "\">View</a>."
    end
  end
end
