#Methods defined here are used everywhere and not only in views, so not in
#<tt>/app/helper</tt> folder.
module Kopal::KopalHelper
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

  #Normalises only a URL, subset of URI.
  #raises URI::InvalidURIError if invalid URI.
  #
  #modified from OpenIdAuthentication::normalize_identifier
  #
  #Must be identity function. i.e.,
  #  normalise_url(normalise_url(id)) = normalise_url(id)
  def normalise_url identifier
    identifier = identifier.to_s.strip
    identifier = "http://#{identifier}" unless identifier =~ /^[^.\?#]+:\/\//i
    raise URI::InvalidURIError unless
      identifier =~ /^[^.]+:\/\/[^\/]+\.[^\/]+/i unless
        identifier =~ /^[^.]+:\/\/localhost/i
    uri = URI.parse(identifier)
    uri.scheme = uri.scheme.downcase  # URI should do this
    identifier = uri.normalize.to_s
  end

  #Must be _identity function_ after first normalise_kopal_identity(id).
  #i.e.,
  #  normalise_kopal_identity(normalise_kopal_identity(id)) = normalise_kopal_identity(id)
  #TODO: Write tests.
  def normalise_kopal_identity identifier
    begin
      identifier = normalise_url identifier
      identifier.gsub!(/\#(.*)$/, '') # strip any fragments
      identifier += '/' unless identifier[-1].chr == '/'
      raise URI::InvalidURIError if identifier['?'] #No query string
      #What about "localhost"?
      #URLs must have atleast on dot.
      #raise URI::InvalidURIError unless identifier =~
        #/^[^.]+:\/\/[0-9a-z]+\.[0-9a-z]+/i #Internationalised domains?, IPv6 addresses?
    rescue URI::InvalidURIError
      raise Kopal::KopalIdentityInvalid, "#{identifier} is not a valid Kopal Identity."
    end
    return identifier
  end

  #Doesn't understands XRI as of now.
  def normalise_openid_identifier identifier
    Kopal::OpenID.normalise_identifier identifier
  end

  def gravatar_url email
    require 'md5'
    hash = MD5.md5 email
    return "http://www.gravatar.com/avatar/#{hash}.jpeg?s=120"
  end

  def can_use_recaptcha?
    ENV['RECAPTCHA_PUBLIC_KEY'] && ENV['RECAPTCHA_PRIVATE_KEY']
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

  #Should be defined in - Kopal::Helper::HtmlHelper maybe.
  def format_date date, without_html = false
    return date unless date.is_a? Date or date.is_a? Time or date.is_a? DateTime

		m = ['Jan', 'Feb', 'March', 'April', 'May', 'June', 'July', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec'] # Oh, we could have done this with strftime() method!
		w = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'] # sunday is 0 for both Time and Date

		current = Time.zone.now #Same as Time.now.utc
    if date.year < current.year
      r = "#{m[date.month-1]}, #{date.year}"
    elsif date.month < current.month or current.mday - date.mday > 1
      r = "#{w[date.wday]}, #{date.mday} #{m[date.month-1]}"
    elsif date.instance_of? Date
      r = "Yesterday"
    elsif current.mday - date.mday == 1
      r = date.strftime("Yesterday, %I:%M%p")
    elsif current.hour > date.hour or current.min - date.min > 20
      r = date.strftime("Today, %I:%M%p")
    elsif current.min - date.min > 2
      r = "Minutes before"
    elsif current.min >= date.min
      r = 'Seconds before'
    else
      r = date.to_s(:long) #date in future?
    end
		return  r if without_html
		return "<abbr title=\"#{date.to_s(:rfc822)}\">#{r}</abbr>"
  end
  alias d format_date
end

#For class methods, "include Kopal::KopalHelper" will do no effect, so we can
#write Kopal::KopalHelperWrapper.new.country_list, instead of writing module_function
#for each method.
class Kopal::KopalHelperWrapper
  include Kopal::KopalHelper
end
