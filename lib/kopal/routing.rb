#Wrapper around named routes.
#Should deprecate it, and use all routes from rails/routing instead?
#Do we really need a wrapper class? Justify.
class Kopal::Routing
  #include ActionController::Routing::Routes.named_routes.instance_variable_get :@module
  #ActionController::Routing::Routes.named_routes.install self

  def initialize controller
    raise "Tried to initialise from a non-kopal controller #{controller.class}" unless
      controller.is_a? Kopal::ApplicationController
    @controller = controller
    #defined here because "rails console" reports that Rails.application is Nil, which might be
    #as "rails console" might be trying to load this class before it has initalised Rails.application.
    self.class.instance_eval { include Rails.application.routes.url_helpers }
  end

  #Homepage of Kopal profile.
  def root hash = {}
    kopal_route_root_path hash
  end

  #Homepage of Kopal profile by default. Accpets actions of Kopal::HomeController
  def home hash = {}
    hash[:controller] = 'kopal/home'
    return root if hash[:action].blank? or hash[:action] == 'index'
    kopal_route_home_path hash.update :trailing_slash => true
  end

  def profile_comment hash = {}
    home hash.update :action => 'comment'
  end

  def kopal_feed hash = {}
    kopal_route_feed_path hash
  end
  alias feed kopal_feed

  def kopal_connect hash = {}
    kopal_route_connect_path hash
  end
  alias connect kopal_connect

  #Usage:
  #    Kopal.route.page 'homepage'
  #    Kopal.route.page :page => 'homepage'
  def page hash = {}
    hash = {:page => hash} if hash.is_a? String
    hash[:trailing_slash] = !hash[:page]
    kopal_route_page_path hash
  end

  def page_draw hash = {}
    kopal_route_page_draw_path hash
  end

  #Or create_page?
  def page_create hash = {}
    page_draw hash.update :action => 'create_page'
  end

  #Or edit_page?
  def page_edit hash = {}
    hash = { :page => hash} if hash.is_a? String
    page_draw hash.update :action => 'edit'
  end

  def page_delete hash = {}
    hash = { :page => hash} if hash.is_a? String
    page_draw hash.update :action => 'delete_page'
  end

  def organise hash = {}
    hash[:controller] = 'kopal/organise'
    kopal_route_organise_path hash
  end

  #+:only_path+ is true by default.
  def xrds hash = {}
    home hash.update :action => 'xrds', :only_path => !!hash[:only_path]
  end

  alias yadis xrds

  def openid_consumer hash = {}
    home hash.update :action => 'openid'
  end

  #+:only_path+ is true by default.
  def openid_consumer_complete hash = {}
    #params[:openid_complete] = 1
    openid_consumer hash.update :only_path => !!hash[:only_path]
  end

  #+:only_path+ is true by default.
  def openid_server hash = {}
    hash[:only_path] = !!hash[:only_path] #Default is false.
    home hash.update :action => 'openid_server'
  end

  #LATER: As per http://www.google.com/support/webmasters/bin/answer.py?answer=76329
  #"edit-identity" should be preferred over "edit_identity", Rails should have some
  #in-built support for matching :action => "edit-identity" to method edit_identity.
  def edit_identity hash = {}
    organise hash.update :action => 'edit_identity'
  end

  def change_password hash = {}
    organise hash.update :action => 'change_password'
  end

  #Usage:
  # * +Kopal.route.stylesheet 'home'+
  # * +Kopal.route.stylesheet :id => 'home', :dont_cache => Time.now+
  def stylesheet hash = 'home'
    hash = {:id => hash} if hash.is_a? String
    hash.update :action => 'stylesheet', :format => 'css', :trailing_slash => false
    home(hash)
  end

  def javascript hash = 'home'
    hash = { :id => hash} if hash.is_a? String
    home hash.update :action => 'javascript', :format => 'js', :trailing_slash => false
  end

  #Unlike stylesheet and javascript, need to pass the file extension too.
  #Ex:
  #    image "ajax-spinner.gif"
  def image hash = {}
    hash = { :id => hash} if hash.is_a? String
    home hash.update :action => 'image', :trailing_slash => false
  end

  #TODO: :format => recognise saved image format.
  #pass a custome name as as hash[:image_name]
  def profile_image hash = {}
    image_name = hash.delete(:image_name) ||
      @controller.instance_variable_get(:@profile_user).feed.name.titlecase.
        gsub(/[\/\\\!\@\#\$\%\^\*\&\-\.\,\?]+/, ' ').gsub(' ', '').underscore
    hash.update :action => 'profile_image', :id =>
      image_name, :format => (hash[:format] || 'jpeg'), :trailing_slash => false
    home(hash)
  end

  def signin hash = {}
    hash.update :action => 'signin'
    home(hash)
  end

  def signout hash = {}
    hash.update :action => 'signout'
    home(hash)
  end

  def kopal_feed hash = {}
    kopal_feed_path hash
  end

  def friend hash = {}
    hash[:action] = 'friend'
    hash[:trailing_slash] = false unless hash[:id].blank?
    home hash
  end

  #@deprecated. Use organise(:action => 'friend') instead.
  #Originally thought that API should be independent of
  #uri i.e., knowing name of action etc, but that is overkill.
  def organise_friend hash = {}
    hash[:action] = 'friend'
    organise hash
  end

private

  #In Rails 3, removing this will raise error -
  #Missing host to link to! Please provide :host parameter or set default_url_options[:host]
  def url_for options = {}
    @controller.url_for options
  end

end

