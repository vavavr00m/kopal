#Methods defined here are used everywhere and not only in views, so not in
#<tt>/app/helper</tt> folder.
module KopalHelper
  #Returns list of countries names in current locale as a Hash indexed by country codes.
  #OPTIMIZE: Fallbacks directly to English.
  def country_list
    I18n.backend.send(:init_translations) unless I18n.backend.initialized?
    t = I18n.backend.send(:translations)
    if t[I18n.locale].blank? or t[I18n.locale][:iso_3166_1_alpha_2].blank?
      return t[:en][:iso_3166_1_alpha_2]
    end
    return t[I18n.locale][:iso_3166_1_alpha_2]
  end

  #Returns a list of cities name in current locale as a Hash indexed by UN/LOCODE
  #OPTIMIZE: Returns only "en" locale.
  #FIXME: For reasons unknown city_list[:"ES NIN"] returns false! (checked in script/console)
  def city_list for_country_code = nil
    I18n.backend.send(:init_translations) unless I18n.backend.initialized?
    code = for_country_code
    t  = I18n.backend.send(:translations)[:en][:un_locode]
    return t unless code
    c = {}
    t.each { |k,v|
      next unless k.to_s =~ Regexp.new("^#{code.upcase} ")
      c[k] = v
    }
    return c
  end

  #modified from OpenIdAuthentication::normalize_identifier
  def normalise_url identifier
    identifier = identifier.to_s.strip
    identifier = "http://#{identifier}" unless identifier =~ /^[^.]+:\/\//i
    identifier.gsub!(/\?(.*)$/, '') #strip query string
    identifier.gsub!(/\#(.*)$/, '') # strip any fragments
    identifier += '/' unless identifier[-1].chr == '/'
    begin
      uri = URI.parse(identifier)
      uri.scheme = uri.scheme.downcase  # URI should do this
      identifier = uri.normalize.to_s
    rescue URI::InvalidURIError
      raise Kopal::InvalidKopalIdentity, "#{identifier} is not a valid Kopal Identity."
    end
    return identifier
  end
end