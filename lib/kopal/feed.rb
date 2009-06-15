#Represents a Kopal Feed
#By default represents a feed for the Profile User
#
#This is a read-only class, and does not modifies Kopal Feeds.
class Kopal::Feed
  include Kopal

  def initialize object = nil
    @of_profile_user = false
    case object
    when REXML::Document
      initialise_for_rexml object
    when String
      if object =~ /^https?:\/\//
        r = Kopal.fetch normalise_url(object)
        object = r.body_xml
      end
      initialise_for_rexml REXML::Document.new(object)
    when ProfileUser
    when nil
      initialise_for_profile_user
    else
      raise ArgumentError, "Unknown type for a Kopal Feed."
    end
  end

  def homepage
    kopal_identity if of_profile_user?
  end

  def kopal_identity
    @kopal_identity
  end

  #This Kopal Feed for profile user?
  def of_profile_user?
    @of_profile_user
  end

  def name
    @name
  end

  def real_name
    @real_name
  end

  def aliases
    @aliases
  end

  def description
    @description
  end

  def image_path
    @image_path
  end

  def gender
    @gender
  end

  def email
    @email
  end

  def birth_time_has_year?
    return false if birth_time.nil?
    0 != birth_time.year
  end

  def birth_time_has_month?
    @birth_time_has_month
  end

  def birth_time_has_day?
    @birth_time_has_day
  end

  #Returns an Object of DateTime
  #Nil if Any of Year, Month, Date can not be determined.
  #
  #For only YYYY-MM, DD may have any legal, set <tt>@birth_time_has_day</tt> to
  #<tt>false</tt>, do same for YYYY too.
  def birth_time
    if of_profile_user?
      return unless b = Kopal[:feed_birth_time]
      case Kopal[:feed_birth_time_pref]
      when 'y'
        @birth_time_has_month = @birth_time_has_day = false
        @birth_time = DateTime.new b.year
      when 'md'
        @birth_time_has_month = @birth_time_has_day = true
        @birth_time = DateTime.new 0, b.month, b.day
      when 'ymd'
        @birth_time_has_month = @birth_time_has_day = true
        @birth_time = DateTime.new b.year, b.month, b.day
      when 'nothing'
        @birth_time_has_month = @birth_time_has_day = false
        @birth_time = nil
      end
    end
  end

  def age
    return nil unless birth_time_has_year?
    next_birthday.year - birth_time.year - 1
  end

  # If today is the birthday, It is still the next birthday.
  #next_birthday - today = days to go
  #next_birthday = today, Happy Birthday!
  def next_birthday
    #requires only month and day and not year.
    return nil unless birth_time_has_month? and birth_time_has_day?
    birthday = Date.new(Date.today.year, birth_time.month,
      birth_time.day)
    return birthday if birthday >= Date.today
    return birthday.next_year
  end

  def birth_time_string
    unless birth_time.blank?
      if birth_time_has_day? #Month is also present
        if birth_time_has_year?
          return birth_time.to_time.strftime("%Y-%m-%d")
        end
        return birth_time.to_time.strftime("%d-%m")
      end
      if birth_time_has_year?
        if birth_time_has_month?
          return birth_time.to_time.strftime("%m-%Y")
        end
        return birth_time.year.to_s
      end
    end
  end

  def country_living_code
    @country_living_code
  end

  def country_living
    @country_living ||=
      country_list[country_living_code.to_sym] unless country_living_code.blank?
  end

  def country_living_with_code
    code = country_living_code
    country_list[code.to_sym] + " (#{code})" unless code.blank?
  end

  def city_has_code?
    !!city_code
  end

  def city_code
    @city_code
  end

  def city_name
    return @city_name ||= if city_has_code?
      city_list[city_code.to_sym]
    elsif of_profile_user?
      Kopal[:feed_city]
    else
    end
  end

  def city_with_code
    return city_name + " (#{city_code})" if city_has_code?
    city_name
  end

  def to_xml
  end

  def to_xml_string
  end

private

  def initialise_for_rexml object
    @of_profile_user = false
    raise KopalFeedInvalid, "Argument is not a valid Kopal Feed." unless
      object.root.name == "KopalFeed"
    raise KopalFeedInvalid, "Attribute \"revision\" for KopalFeed is required." if
      object.root.attributes["revision"].blank?
    e = object.root.elements
    i = e["Identity"]
    ie = i.elements
    raise KopalFeedInvalid, "Element Homepage is required." if
      ie["Homepage"].blank?
    raise KopalFeedInvalid, "Element RealName is required." if
      ie["RealName"].blank?
    @homepage = ie["Homepage"].text
    @kopal_identity = ie["KopalIdentity"].text if ie["KopalIdentity"]
    @name = @real_name = ie["RealName"].text
    unless ie["Aliases"].nil?
      @aliases = []
      ie["Aliases"].each { |a|
        next unless a.node_type == :element
        raise KopalFeedInvalid, "Identity.Aliases has invalid element " +
          "\"#{a.name}\"" unless a.name == "Alias"
        @aliases << a.text
        @name = a.text if a.attributes["preferred_calling_name"]
      }
    end
    @description = ie["Description"].text if ie["Description"]
    @image_path = ie["Image"].text if ie["Image"] and ie["Image"].attributes["type"] == "url"
    if ie["Gender"]
      raise KopalFeedInvalid, "Gender must be \"Male\" or \"Female\"." unless
        ie["Gender"].text =~ /^(M|Fem)ale$/
      @gender = ie["Gender"].text
    end
    if ie["Email"]
      begin
        e = TMail::Address.parse(ie["Email"].text)
        @email = e.address # Vi <vi@example.net> => vi@example.net
      rescue TMail::SyntaxError
        raise KopalFeedInvalid, "Email does not has a valid syntax."
      end
    end
    if ie["BirthTime"]
      case ie["BirthTime"].text
      when /^[0-9]{4}$/ #YYYY
        @birth_time_has_month = @birth_time_has_day = false
        @birth_time = DateTime.new ie["BirthTime"].text.to_i
      when /^[0-9]{4}-[0-9]{2}$/ #YYYY-MM
        @birth_time_has_month = true
        @birth_time_has_day = false
        @birth_time = DateTime.new ie["BirthTime"].text[0,4].to_i,
          ie["BirthTime"].text[5,2].to_i
      when /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/ #YYYY-MM-DD
        @birth_time_has_month = @birth_time_has_day = true
        @birth_time = DateTime.new ie["BirthTime"].text[0,4].to_i,
          ie["BirthTime"].text[5,2].to_i, ie["BirthTime"].text[8,2].to_i
      when /^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}.[0-9]{2,}Z$/
        #TODO: Write me.
      else
        raise KopalFeedInvalid, "BirthTime does not has a valid syntax."
      end
    end
    if ie["Address"]
      if ie["Country"]
        if ie["Living"]
          @country_living_code = ie["Living"].text
          raise KopalFeedInvalid, "Identity.Address.Country.Living " +
            "\"#{@country_living_code}\" is not valid country code." unless
          country_living
        end
      end
    end
  end

  def initialise_for_profile_user
    @of_profile_user = true
    @real_name = (Kopal[:feed_real_name] || "Profile user").strip
    @name = (Kopal[:feed_preferred_calling_name] || @real_name).strip
    @aliases = Kopal[:feed_aliases].to_s.split("\n").map { |e| e.strip}
    @description = Kopal[:feed_description]
    @gender = if(Kopal[:feed_show_gender] == 'yes')
      Kopal[:feed_gender].to_s.titlecase
    end
    @email = if(Kopal[:feed_show_email] == 'yes')
      Kopal[:feed_email].to_s
    end
    @country_living_code = Kopal[:feed_country_living_code].to_s.upcase
    if 'yes' == Kopal[:feed_city_has_code]
      @city_code = Kopal[:feed_city]
    end
  end

end