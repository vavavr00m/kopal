# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require 'ostruct'
require 'rexml/document' #Host server of its.raining.in is not loading REXML::Document automagically, while local server on my local machine does.
#TODO: Place <tt>div#SurfaceLeft</tt> after <tt>div#SurfaceFront</tt> using some
#      negative margin CSS technique in <tt>layout.html.erb</tt>
#TODO: Hook in mercurial to run all test successfully before commit.
require_dependency Kopal.root.join('rails/app/helpers/kopal/application_helper').to_s #no autoloading!
class Kopal::ApplicationController < ApplicationController
  helper :all # include all helpers, all the time
  helper Kopal::ApplicationHelper
  helper Kopal::KopalHelper #in views
  include Kopal::KopalHelper #in controllers
  include Kopal::OpenID::ControllerHelper
  before_filter :initialise_for_kopal
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
    redirect_to(@kopal_route.signin(:and_return_to => request.request_uri)) and
      return false unless @visiting_user.homepage?
    true
  end

  #example usages -
  #render_kopal_error("This is my error message")
  #render_kopal_error(0x1234)
  #render_kopal_error(0x1234, "show this error message instead of default with this error code")
  #TODO: Implement following.
  #render_kopal_error(0x1202, {:state => 'invalid'})
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

  def render_404 message = nil
    #head :not_found
    render :file => Rails.root.join('public', '404.html'), :status => :not_found
  end
  
private

  #TODO: Save Kopal Identity in database, and next time if
  # <tt>@kopal_route.root</tt> doesn't match <tt>@profile_user.kopal_identity</tt>
  # then generate error saying that "This Kopal Identity is meant to be accessed from
  # #{@profile_user.kopal_identity}.". This will prevent potential errors arising
  # from presence/absemce of 'www' in domain or other minor changes in URI that
  # may interfare with Kopal Connect as Kopal Identity is an integrated part of it.
  def initialise_for_kopal
    session[:kopal] = {} unless session[:kopal].is_a? Hash
    Kopal.initialise
    self.prepend_view_path Kopal.path.rails.views.to_s
    if Kopal.multiple_profile_interface?
      if kopal_determine_profile_identifier
        identifier, identity = kopal_determine_profile_identifier
        @profile_user = Kopal::ProfileUser.new Kopal::KopalAccount.
          find_by_identifier_from_application identifier
        @profile_user.kopal_identity = identity
      else
        if params[:controller] == 'kopal/home' and params[:action] == 'index' and Kopal.redirect_for_home
          redirect_to Kopal.redirect_for_home
          return
        end
        render_404 "Can not find requested Kopal profile."
        return
      end
    else
      check_for_incomplete_migration!
      @profile_user = Kopal::ProfileUser.new Kopal::KopalAccount.default_profile_account
    end

    @kopal_route = Kopal::Routing.new self
    @profile_user.route = @kopal_route
    I18n.locale = params[:culture]
    set_response_headers
    authenticate_visiting_user if params[:"kopal.visitor"]
    @_page = Kopal::PageView.new @profile_user
    @profile_user.mark_signed! if @profile_user.kopal_identity.to_s == session[:kopal][:signed_kopal_identity]
    @visiting_user = Kopal::VisitingUser.new session[:kopal][:signed_kopal_identity], @profile_user.signed?
    set_page_variables
    actions_for_signed_user_visiting_homepage if @visiting_user.homepage?
  end

  def set_response_headers
    response.headers['X-XRDS-Location'] = kopal_route_home_path #@kopal_route.xrds
  end

  def authenticate_visiting_user
    return if params[:"kopal.visitor"] == session[:kopal][:signed_kopal_identity]
    redirect_to @kopal_route.home :action => 'signin_for_visitor', :openid_identifier =>
      params[:'kopal.visitor'], :return_path => url_for(:only_path => true)
  end

  def set_page_variables
    #When theme support is implemented, these should go to theme controller.
    @_page.add_stylesheet 'home'
  end

  def actions_for_signed_user_visiting_homepage
    return
    #TODO: some tasks should only run on single profile interface and only on default profile.
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

  def check_for_incomplete_migration!
    if Kopal::KopalModel.migration_needed?
      render :text => "Kopal needs to be updated first.\n" +
        "Please run <code>rake kopal:update RAILS_ENV=#{RAILS_ENV}</code> to update."
    end
  end
end
