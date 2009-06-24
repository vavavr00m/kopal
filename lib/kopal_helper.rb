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
  #Must be _identity function_ after first normalise_url(id).
  #i.e., normalise_url(normalise_url(id)) == normalise_url(id) #=> true
  #TODO: Write tests.
  def normalise_url identifier
    identifier = identifier.to_s.strip
    identifier = "http://#{identifier}" unless identifier =~ /^[^.]+:\/\//i
    identifier.gsub!(/\?(.*)$/, '') #strip query string
    identifier.gsub!(/\#(.*)$/, '') # strip any fragments
    identifier += '/' unless identifier[-1].chr == '/'
    begin
      #URLs must have atleast on dot.
      raise URI::InvalidURIError unless identifier =~
        /^[^.]+:\/\/[0-9a-z]+\.[0-9a-z]+/i #Internationalised domains?, IPv6 addresses?
      uri = URI.parse(identifier)
      uri.scheme = uri.scheme.downcase  # URI should do this
      identifier = uri.normalize.to_s
    rescue URI::InvalidURIError
      raise Kopal::KopalIdentityInvalid, "#{identifier} is not a valid Kopal Identity."
    end
    return identifier
  end

  #Argument n is the length of resulting hexadecimal string or Range of length.
  def random_hexadecimal n = 32
    if n.is_a? Range
      #n.to_a[-1] = last element since (2..7).last == (2...7).last
      n = rand(n.to_a[-1] - n.first + 1) + n.first
    end
    ActiveSupport::SecureRandom.hex(n/2)
  end

  def valid_hexadecimal? s
    s =~ /^[a-f0-9]*$/i #Empty string is valid Hexadecimal.
  end
end