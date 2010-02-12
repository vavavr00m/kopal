#Class which holds information (mainly markup) of the page being displayed.
class Kopal::PageView

  NEWEST_VERSION_PROTOTYPE = '1.6' #or latest?
  NEWEST_VERSION_SCRIPTACULOUS = '1.8'

  def initialize profile_user
    @profile_user = profile_user
    @kopal_route = @profile_user.route
  end

  #alias for constant +RAILS_ENV+.
  def environment
    RAILS_ENV
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
    add_javascript(if production_env?
      ajaxlib_prototype_path
    else
      'prototype'
    end)
    @included_prototype = true
  end

  #Includes the Script.aculo.us library in page.
  #Fetches files from Google Ajaxlibs if in production environment.
  #Don't forget to include Prototype first.
  def include_scriptaculous
    return if @included_scriptaculous
    add_javascript(if production_env?
      ajaxlib_scriptaculous_path
    else
      'scriptaculous'
    end)
    @included_scriptaculous = true
  end

private

  def ajaxlib_prototype_path version = nil
    version ||= NEWEST_VERSION_PROTOTYPE
    "http://ajax.googleapis.com/ajax/libs/prototype/#{version}/prototype.js"
  end

  def ajaxlib_scriptaculous_path version = nil
    version ||= NEWEST_VERSION_SCRIPTACULOUS
    "http://ajax.googleapis.com/ajax/libs/scriptaculous/#{version}/scriptaculous.js"
  end

  def title_postfix
    "#{@profile_user} #{title_separator} Kopal Profile"
  end
end
