#Class which holds information (mainly markup) of the page being displayed.
class Kopal::PageView

  #alias for constant +RAILS_ENV+.
  def environment
    RAILS_ENV
    #"production" # uncomment for quick testing.
  end

  def production_env?
    environment == "production"
  end

  def title
    @title ||= "#{Kopal.profile_user}" + title_postfix
  end

  def title= value
    @title = value.to_s + title_postfix
  end

  def description
    @description ||= "Social profile of #{Kopal.profile_user}."
  end

  def description= value
    @description = value
  end

  #Yadis/XRDS discovery meta tags for user.
  def meta_yadis_discovery
    '<meta http-equiv="X-XRDS-Location" content="' + Kopal.route.xrds + '">'
  end

  #OpenID discovery meta tags.
  def meta_openid_discovery
    '<link rel="openid2.provider" href="' + Kopal.route.openid_server + '">' +
       "\n" + '<link rel="openid2.local_id" href="' + Kopal.identity.to_s + '">'
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

  def javascripts
    @javascripts ||= []
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

  def include_google_analytics?
    !!google_analytics_code
  end

  def google_analytics_code
    Kopal[:widget_google_analytics_code]
  end

private

  def ajaxlib_prototype_path version = false
    'http://ajax.googleapis.com/ajax/libs/prototype/1.6/prototype.js'
  end

  def ajaxlib_scriptaculous_path version = false
    'http://ajax.googleapis.com/ajax/libs/scriptaculous/1.8/scriptaculous.js'
  end

  def title_postfix
    " | Kopal Profile"
  end
end