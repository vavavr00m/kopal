#Class which holds information (mainly markup) of the page being displayed.
#TODO: Re-think about this class. Do we really need this (Maybe for themes). And should it go to "kopal" or "kopal-rails"?
class Kopal::PageView

  NEWEST_VERSION_PROTOTYPE = '1.6' #or latest?
  NEWEST_VERSION_SCRIPTACULOUS = '1.8'

  def initialize profile_user
    @profile_user = profile_user
    @kopal_route = @profile_user.route
  end

  #alias for constant +RAILS_ENV+.
  def environment
    Rails.env
    #"production" # uncomment for quick testing.
  end

  def production_env?
    environment == "production"
  end

  #Append title in already created onw
  #Usage:
  #    @_page.title <<= 'Appened title'
  def title
    @title ||= []
  end

  #Used to set the absolute value for title.
  #
  #If passed as an Array, each value will be separated by title_separator
  #Usage:
  #    title = "Hello, world!" #=> Hello, world! - Name - Kopal Profile
  #    title = ["Hello", "world"] #=> Hello - world - Name - Kopal Profile
  def title= value
    value = [value] if value.is_a? String
    @title = value
  end

  def show_title
    if @title.blank?
      return title_postfix
    end
    @title.reverse.join(' ' + title_separator + ' ') + ' | ' + title_postfix
  end

  def title_separator
    @title_separator ||= "|" #//, &ndash;, |, /
  end

  def title_separator= value
    @title_separator = value
  end

  def description
    @description ||= "Social profile of #{@profile_user}."
  end

  def description= value
    @description = value
  end

  #Yadis/XRDS discovery meta tags for user.
  def meta_yadis_discovery
    '<meta http-equiv="X-XRDS-Location" content="' + @kopal_route.xrds + '">'
  end

  #OpenID discovery meta tags.
  def meta_openid_discovery
    '<link rel="openid2.provider" href="' + @kopal_route.openid_server + '">' +
       "\n" + '<link rel="openid2.local_id" href="' + @profile_user.kopal_identity.to_s + '">'
  end

  def stylesheets
    @stylesheets ||= []
  end

  #Usage:
  #    add_stylesheet('home')
  #    add_stylesheet( :name => 'home', :media => 'all')
  def add_stylesheet value
    stylesheets #initialise
    @stylesheets << value
  end

  #TODO: If in production mode if hg revision is known, include all static Kopal related JavaScript files 
  #directly from http://kopal.googlecode.com/hg/lib/app/views/siterelated/home.js?r=revision-id
  #revision-id can be found from .hg_archival.txt
  def javascripts
    @javascripts ||= [@kopal_route.javascript('dynamic'), @kopal_route.javascript('home')]
  end

  def add_javascript value
    javascripts #initialise
    @javascripts << value
  end

  #Includes the Protoype library in page.
  #Fetches files from Google Ajaxlibs if in production environment.
  def include_prototype
    return if @included_prototype
    add_javascript prototype_js_url
    @included_prototype = true
  end

  #Includes the Script.aculo.us library in page.
  #Fetches files from Google Ajaxlibs if in production environment.
  #Don't forget to include Prototype first.
  def include_scriptaculous
    return if @included_scriptaculous
    add_javascript scriptaculous_js_url
    @included_scriptaculous = true
  end

  def include_yui
    return if @included_yui
    add_javascript(yui_cdn_yui3_path)
    @included_yui = true
  end

  def yui_cdn_yui3_path
    DeprecatedMethod.here "Use yui3_js_url() instead."
    yui3_js_url
  end
  
  def include_jquery
    return if @included_jquery
    add_javascript "https://ajax.googleapis.com/ajax/libs/jquery/1.6.0/jquery.min.js"
    @included_jquery = true
  end
  
  def include_jquery_ujs
    return if @included_jquery_ujs
    add_javascript @kopal_route.javascript('rails-jquery')
    @included_jquery_ujs = true
  end

  #Or js_yui3_url()?
  #Like <tt>read_record()</tt> and <tt>write_record()</tt> OR <tt>record_read()</tt>, <tt>record_write()</tt>.
  #Need to stick to one style. Which one, and why?
  def yui3_js_url
    if production_env?
      yahoo_cdn_yui3_min_url
    else
      yahoo_cdn_yui3_debug_url
    end
  end

  def prototype_js_url
    if production_env?
      ajaxlib_prototype_url
    else
      'prototype'
    end
  end

  def scriptaculous_js_url
    if production_env?
      ajaxlib_scriptaculous_url
    else
      'scriptaculous'
    end
  end

private

  def ajaxlib_prototype_url version = nil
    version ||= NEWEST_VERSION_PROTOTYPE
    "http://ajax.googleapis.com/ajax/libs/prototype/#{version}/prototype.js"
  end

  def ajaxlib_scriptaculous_url version = nil
    version ||= NEWEST_VERSION_SCRIPTACULOUS
    "http://ajax.googleapis.com/ajax/libs/scriptaculous/#{version}/scriptaculous.js"
  end

  def yahoo_cdn_yui3_min_url
    "https://ajax.googleapis.com/ajax/libs/yui/3.3.0/build/yui/yui-min.js"
  end

  def yahoo_cdn_yui3_debug_url
    "https://ajax.googleapis.com/ajax/libs/yui/3.3.0/build/yui/yui-debug.js"
  end

  def title_postfix
    "#{@profile_user} #{title_separator} Kopal Profile"
  end
end
