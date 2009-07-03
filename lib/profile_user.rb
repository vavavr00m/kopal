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
    Kopal::Identity.new i
  end
  alias profile_identity kopal_identity
  alias profile_homepage kopal_identity
  alias homepage kopal_identity
  alias profile_url kopal_identity

  def kopal_feed_url
    DeprecatedMethod.here "Use .kopal_identity.feed_url() instead."
    kopal_identity.feed_url
  end

  #User has created her Identity?
  #Identity is the core part of user's profile. (not to be confused with
  #kopal_identity.)
  def created_identity?
    !!Kopal[:feed_real_name]
  end

  def feed
    @kopal_feed ||= Kopal::Feed.new
  end
  
  def name
    DeprecatedMethod.here "Use .feed.name() instead."
    feed.name
  end
  alias preferred_calling_name name

  def real_name
    DeprecatedMethod.here "Use .feed.real_name() instead."
    feed.real_name
  end
  
  def aliases
    DeprecatedMethod.here "Use .feed.aliases() instead."
    feed.aliases
  end

  #Duplication? !DRY?
  def status_message
    Kopal[:user_status_message]
  end

  def description
    DeprecatedMethod.here "Use .feed.description() instead?"
    feed.description
  end

  def image_path
    kopal_identity.to_s + 'home/profile_image/' +
      feed.name.titlecase.gsub(/[\/\\\!\@\#\$\%\^\*\&\-\.\,\?]+/, ' ').
      gsub(' ', '').underscore + '.jpeg'
  end

  def gender
    DeprecatedMethod.here "Use .feed.gender() instead."
    feed.gender
  end

  def email
    DeprecatedMethod.here "Use .feed.email() instead."
    feed.email
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
    DeprecatedMethod.here "Use .feed.age() instead."
    feed.age
  end

  def birth_time
    DeprecatedMethod.here "Use .feed.birth_time_string() instead."
    feed.birth_time_string
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
    unless feed.birth_time.blank?
      #age_string = " (#{age} #{t(:year, :count => year).downcase})"
      age_string = " (#{feed.age} years)"
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
    DeprecatedMethod.here "Use .feed.next_birthday() instead."
    feed.next_birthday
  end

  def country_living_code
    DeprecatedMethod.here "Use .feed.country_living_code() instead."
    feed.country_living_code
  end

  def country_living
    DeprecatedMethod.here "Use .feed.country_living() instead."
    feed.country_living
  end

  #Country living in format => Country (CODE)
  def country_living_with_code
    DeprecatedMethod.here "Use .feed.country_living_with_code() instead."
    feed.country_living_with_code
  end

  def city_has_code?
    DeprecatedMethod.here "Use .feed.city_has_code?() instead."
    feed.city_has_code?
  end

  #Name of the city.
  def city
    DeprecatedMethod.here "Use .feed.city_name() instead."
    feed.city_name
  end

  def city_code
    DeprecatedMethod.here "Use .feed.city_code() instead."
    feed.city_code
  end

  def city_with_code
    DeprecatedMethod.here "Use .feed.city_with_code() instead."
    feed.city_with_code
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
    Kopal::UserFriend.find_all_by_friendship_state("friend")
  end

  #Returns false if not friend, else the friendship state
  def friend? friend_identity
    f = Kopal::UserFriend.find_by_kopal_identity(normalise_url(friend_identity.to_s))
    return false if f.nil?
    return f.friendship_state == 'friend'
  end

  #Validate the friendship state for all or specific friend.
  #Ends with ! since requires network resource.
  def validate_friendship! specific_friend = nil
    #TODO: Write me
    raise NoMetodError
  end
end
