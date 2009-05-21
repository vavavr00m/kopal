#Users, whom this application belongs to.
class ProfileUser < KopalUser
  #User has created her Identity?
  #Identity is the core part of user's profile.
  def created_identity?
    !!Kopal[:feed_name]
  end
  
  def name
    Kopal['preferred_calling_name'] || Kopal['feed_name'] ||
      'Profile user'
  end

  def aliases
    Kopal[:feed_aliases].split("\n")
  end

  #Duplication? !DRY?
  def status_message
    Kopal[:user_status_message]
  end

  def description
    Kopal[:feed_description]
  end

  def gender
    #t(Kopal[:feed_gender])
    Kopal[:feed_gender].to_s.titlecase
  end

  def age
    return nil if Kopal[:feed_birth_time].blank?
    next_birthday.year - Kopal[:feed_birth_time].year - 1
  end

  #Returns the date of birth as string, followed by age in brackets.
  #Respects date of birth preference in +Kopal[:feed_birth_time_pref]+
  def dob_string
    unless Kopal[:feed_birth_time].blank?
      year = Kopal[:feed_birth_time].year
      #age_string = " (#{age} #{t(:year, :count => year).downcase})"
      age_string = " (#{age} years)"
      return case Kopal[:feed_birth_time_pref]
      when 'y':
        year.to_s + age_string
      when 'md':
        Kopal[:feed_birth_time].to_time.strftime("%d-%b")
      when 'ymd':
        Kopal['feed_birth_time'].to_time.strftime("%d-%b-%Y") + age_string
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

  def country
    ApplicationHelper.country_list[Kopal[:feed_country_living_code].to_sym]
  end

  #Country living in format => Country (CODE)
  def country_with_code
    code = Kopal[:feed_country_living_code]
    ApplicationHelper.country_list[code.to_sym] + " (#{code})" unless code.blank?
  end

  def city
    if Kopal[:feed_city_has_code] == 'yes'
      return ApplicationHelper.city_list[Kopal[:feed_city].to_sym]
    end
    Kopal[:feed_city]
  end

  def city_with_code
    if Kopal[:feed_city_has_code] == 'yes'
      return city + " (#{Kopal[:feed_city]})"
    end
    Kopal[:feed_city]
  end
end
