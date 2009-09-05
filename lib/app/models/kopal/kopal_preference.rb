#Holds all the data of user too, since there is only one user, No need for UserAccount model.
class Kopal::KopalPreference < Kopal::KopalModel
  class InvalidFieldName < StandardError; end;
  set_table_name :kopal_preference
  serialize :preference_text

  #Only these values can be stored in the <tt>preference_name</tt> field. (extreme programming?).
  #It is up to Controller to choose a default value for fields.
  FIELDS = [
    :authentication_method,
    :account_password, #TODO: Hash it with salt.
    :feed_real_name, #Name of the user
    :feed_aliases, #Aliases of the user separated by "\n"
    :feed_preferred_calling_name,
    :user_status_message,
    :feed_description, #Description of the user
    :feed_email, #Email of user.
    :feed_show_email, #Only <tt>yes</tt> or <tt>no</tt> downcase.
    :feed_gender, #Gender of the user, must be only <tt>male</tt> or <tt>female</tt> downcase.
    :feed_show_gender, #must be only <tt>yes</tt> or <tt>no</tt> downcase.
    :feed_birth_time, #Date of birth of user. Must be an instance of DateTime
    :feed_birth_time_pref, #Value must be one of <tt>ymd</tt> <tt>y</tt> <tt>md</tt>
      #or <tt>nothing</tt>. <tt>y, m, d</tt> stand for <tt>year, month, date</tt> resp.
    :feed_country_living_code, #Code for living country.
    :feed_city, #Name of the city or its code. Determined by <tt>city_has_code</tt>
    :feed_city_has_code, #Must be either <tt>yes</tt> or <tt>no</tt> downcase.
    :kopal_identity,
    #Encode Private key with Base64 before saving to database. Since private key starts with "--" and
    #value is serialised and ActiveRecord screws up and replaces "\n"
    #with " ".
    :kopal_encoded_private_key,
    :widget_google_analytics_code,
    :meta_upgrade_last_check
  ]
  DEPRECATED_FIELDS = {
    #:deprecated_field => "message"
  }
  DEFAULT_VALUE = {
    :authentication_method => 'simple',
    :account_password => 'secret01',
    :feed_show_gender => 'yes'
  }
  def self.all_fields
    (FIELDS.dup.concat(DEPRECATED_FIELDS.keys)).map { |k| k.to_s }
  end
  
  validates_presence_of :preference_name
  validates_uniqueness_of :preference_name
  validates_inclusion_of :preference_name,
    :in => self.all_fields,
    :message => "{{value}} is not in the list."
  before_validation :preference_name_in_lowercase

  #OPTIMIZE: Internationalise/Localise it.
  def validate
    name = self.preference_name
    text = self.preference_text
    case name
    when "feed_name":
      errors.add_to_base('Name must not be blank') if text.blank?
    when "feed_email":
      begin
        e = TMail::Address.parse(text)
        self.preference_text = e.address # Vi <vi@example.net> => vi@example.net
      rescue TMail::SyntaxError
        errors.add_to_base('"feed_email" is not a valid Email')
      end
    when "feed_gender":
      errors.add_to_base('Gender must be "Male" or "Female"') unless
        text =~ /^Male|Female$/ #case sensitive
    when /^feed_show_email|feed_show_gender|feed_city_has_code$/:
      errors.add_to_base('"' + name + '" must be either <tt>yes</tt> or <tt>no</tt>') unless
        text =~ /^yes|no$/
    when "feed_birth_time":
      errors.add_to_base('"feed_birth_time" must be an instance of DateTime') unless
        text.is_a? DateTime
    when "feed_birth_time_pref":
      errors.add_to_base('"birth_time_pref" must be one of "y", "ymd", "md", "nothing".') unless
        text =~ /^ymd|y|md|nothing$/
    when "feed_country_living_code":
      errors.add_to_base('Country code must be of length 2 in upper-case.') unless
        text =~ /^[A-Z]{2}$/
      errors.add_to_base('Country code is not a valid country code') unless
        country_list.include? text.to_sym
    when "widget_google_analytics_code"
      errors.add_to_base("Wrong Google Analytics code") unless text =~ /^UA\-[a-zA-Z0-9]+\-[0-9]+$/
    when "meta_upgrade_last_check"
      errors.add_to_base("#{name} must be an instance of Time") unless text.is_a? Time
    end
  end

  #Get a preference value. Also see Kopal#[] for shorthand.
  def self.get_field name
    deprecated? name
    s = self.find_by_preference_name(name)
    return( s ? s.preference_text : DEFAULT_VALUE[name.to_sym])
  end

  #Saves a preference to the database. Also see Kopal#[]= for a shorthand.
  def self.save_field name, value
    deprecated? name
    s = self.find_or_initialize_by_preference_name(name)
    s.preference_text = value;
    s.save!
    s.preference_text
  end

  #TODO: Write me
  def self.delete_field name
  end

  def self.deprecated? name
    raise Kopal::KopalPreference::InvalidFieldName, 'Preference name ' + name.to_s +
      ' is not valid.' unless all_fields.include? name.to_s
    DeprecatedMethod.here DEPRECATED_FIELDS[name.to_sym] if
      DEPRECATED_FIELDS.has_key? name.to_sym
  end

private
  def preference_name_in_lowercase
    self.preference_name = self.preference_name.to_s.downcase
  end
end

