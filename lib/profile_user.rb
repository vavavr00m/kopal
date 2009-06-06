#Users, whom this application belongs to.
class ProfileUser < KopalUser
  
  def kopal_identity
    r = ApplicationController.request
    if((i = Kopal[:kopal_identity]).blank?())
      i = r.protocol
      i += r.host
      i += r.port_string unless((r.protocol == 'htp://' && r.port == 80) ||
        (r.protocol == 'https://' && r.port == 443))
    end
    normalise_url(i)
  end
  alias profile_identity kopal_identity
  alias profile_homepage kopal_identity
  alias homepage kopal_identity
  alias profile_url kopal_identity

  def kopal_feed_url
    kopal_identity + 'home/feed/' #Can't use kopal_feed_url or url_for
  end

  #User has created her Identity?
  #Identity is the core part of user's profile. (not to be confused with
  #profile_identity.)
  def created_identity?
    !!Kopal[:feed_name]
  end
  
  def name
    (Kopal[:feed_preferred_calling_name] || real_name).strip
  end
  alias preferred_calling_name name

  def real_name
    (Kopal[:feed_name] || 'Profile user').strip
  end
  
  def aliases
    Kopal[:feed_aliases].to_s.split("\n").map { |e| e.strip}
  end

  #Duplication? !DRY?
  def status_message
    Kopal[:user_status_message]
  end

  def description
    Kopal[:feed_description]
  end

  def image_path
    kopal_identity + 'home/profile_image/' +
      name.titlecase.gsub(/[\/\\\!\@\#\$\%\^\*\&\-\.\,\?]+/, ' ').
      gsub(' ', '').underscore + '.jpeg'
  end

  def gender
    if(Kopal[:feed_show_gender] == 'yes')
      Kopal[:feed_gender].to_s.titlecase
    end
  end

  def email
    if(Kopal[:feed_show_email] == 'yes')
      Kopal[:feed_email].to_s
    end
  end

  def show_dob?
    return false if Kopal[:feed_birth_time_pref] == 'nothing'
    return true
  end

  def can_show_age?
    return true if Kopal[:feed_birth_time_pref] =~ /^y/
    return false
  end

  def age
    return nil if Kopal[:feed_birth_time].blank?
    next_birthday.year - Kopal[:feed_birth_time].year - 1
  end

  def birth_time #In ISO 8601
    unless Kopal[:feed_birth_time].blank?
      return case Kopal[:feed_birth_time_pref]
      when 'y':
        Kopal[:feed_birth_time].year.to_s
      when 'ymd':
        Kopal[:feed_birth_time].to_time.strftime("%Y-%m-%d")
      end
    end
  end

  def dob_string
    unless Kopal[:feed_birth_time].blank?
      year = Kopal[:feed_birth_time].year
      return case Kopal[:feed_birth_time_pref]
      when 'y':
        year.to_s 
      when 'md':
        Kopal[:feed_birth_time].to_time.strftime("%d-%b")
      when 'ymd':
        Kopal['feed_birth_time'].to_time.strftime("%d-%b-%Y")
      end
    end
    return ''
  end
  
  #Returns the date of birth as string, followed by age in brackets.
  #Respects date of birth preference in +Kopal[:feed_birth_time_pref]+
  def dob_with_age
    unless Kopal[:feed_birth_time].blank?
      #age_string = " (#{age} #{t(:year, :count => year).downcase})"
      age_string = " (#{age} years)"
      return case Kopal[:feed_birth_time_pref]
      when /y|md/:
        dob_string + age_string
      when /md/:
        dob_string
      end
    end
    return ''
  end

  def next_birthday
    return nil if Kopal[:feed_birth_time].blank?
    birthday = Date.new(Date.today.year, Kopal[:feed_birth_time].month,
      Kopal[:feed_birth_time].day)
    return birthday if birthday >= Date.today
    return birthday.next_year
  end

  def country_living_code
    Kopal[:feed_country_living_code].to_s.upcase
  end

  def country_living
    country_list[Kopal[:feed_country_living_code].to_sym]
  end

  #Country living in format => Country (CODE)
  def country_living_with_code
    code = Kopal[:feed_country_living_code]
    country_list[code.to_sym] + " (#{code})" unless code.blank?
  end

  def city_has_code?
    Kopal[:feed_city_has_code] == 'yes'
  end

  #Name of the city.
  def city
    if city_has_code?
      return city_list[Kopal[:feed_city].to_sym]
    end
    Kopal[:feed_city]
  end

  def city_code
    Kopal[:feed_city].to_s if city_has_code?
  end

  def city_with_code
    if Kopal[:feed_city_has_code] == 'yes'
      return city + " (#{Kopal[:feed_city]})"
    end
    Kopal[:feed_city]
  end

  #USE WITH CAUTION!
  #Returns an instance of OpenSSL::PKey::RSA
  def private_key!
    if Kopal[:kopal_encoded_private_key].blank?
      regenerate_private_key!
    end
    OpenSSL::PKey::RSA.new Base64::decode64(Kopal[:kopal_encoded_private_key])
  end

  def public_key
    private_key!.public_key
  end

  #Default is 2048, recommended by RSA see -
  #http://www.rsa.com/rsalabs/node.asp?id=2004#table1
  #http://www.rsa.com/rsalabs/node.asp?id=2218
  #We don't need to be very future-proof beccause
  #We ain't encrypting any private data, where eve stores cipher text today, and analyses
  #it when technology becomes feasible.
  #Also, Private key can be changed over time so age of value of a cipher text of today is
  #as long as user changes the Private key.
  #Also note that identity of a user is tied with her Kopal Identity (profile url)
  #and not with her private key.
  def private_key_length
    #Kopal[:kopal_private_key_length] ||
      2048
  end

  #Will invalidate everything done in past!
  #Encode Private key before saving to database. Since private key starts with "--" and
  #value is serialised ActiveRecord screws up and replaces "\n"
  #with " ".
  def regenerate_private_key!
    Kopal[:kopal_encoded_private_key] =
      Base64::encode64(OpenSSL::PKey::RSA.new(private_key_length).to_pem)
  end

  def friends
    UserFriend.all
  end

  def friend? friend_identity
    !!UserFriend.find_by_kopal_identity(normalise_url(friend_identity))
  end
end
