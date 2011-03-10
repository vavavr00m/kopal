#Preferences related to a profile, account, user or Kopal itself.
class Kopal::Preference < Kopal::Model
  class InvalidFieldName < Kopal::Exception::KopalError; end;
  
  field :name
  #Is it possible that type of field "value" is dynamic? Say can store
  #an Array for some records, Interger for some, Boolean for some and String for some?
  field :value
  embedded_in :preference_for, :inverse_of => :preferences

  index :name, :unique => true


  #Temporary preferences for one time user, might not be included in backups.
  #Shouldn't they be saved in sessions/cookies?
  TEMP_PREFERENCE_NAME_PREFIX = "temp_"

  #Only these values can be stored in the <tt>name</tt> field. (extreme programming?).
  #unless they start with "temp_"
  #It is up to Controller to choose a default value for fields.
  #
  #TODO: This shouldn't be treated as dumping ground, move related fields to respective models.
  #For example - +status_message+ can go to Kopal::Profile and
  #all fields for +feed+ can go to a new class Kopal::FeedData
  FIELDS = {
    :authentication_method => 'password',
    #SHA-512 password hash
    :account_password_hash => nil,
    #512-bit salt.
    :account_password_salt => nil,
    :profile_status_message => nil,
    #Name of the user
    :feed_real_name => nil,
    #Aliases of the user separated by "\n"
    :feed_aliases => nil,
    :feed_preferred_calling_name => nil,
    #Description of the user
    :feed_description => nil,
    #Email of user.
    :feed_email => nil,
    #Only <tt>true</tt> or <tt>false</tt> downcase.
    :feed_show_email => nil,
    #Gender of the user, must be only <tt>male</tt> or <tt>female</tt> downcase.
    :feed_gender => nil,
    #must be only <tt>true</tt> or <tt>false</tt> downcase.
    :feed_show_gender => "true",
    #Date of birth of user. Must be an instance of DateTime
    :feed_birth_time => nil,
    #Value must be one of <tt>ymd</tt> <tt>y</tt> <tt>md</tt>
    #or <tt>nothing</tt>. <tt>y, m, d</tt> stand for <tt>year, month, date</tt> resp.
    :feed_birth_time_pref => nil,
    #Code for living country.
    :feed_country_living_code => nil,
    #Name of the city or its code. Determined by <tt>city_has_code</tt>
    :feed_city => nil,
    #Must be either <tt>yes</tt> or <tt>no</tt> downcase.
    :feed_city_has_code => nil,
    :kopal_identity => nil,
    #Encode Private key with Base64 before saving to database. Since private key starts with "--" and
    #value is serialised and ActiveRecord screws up and replaces "\n"
    #with " ".
    :kopal_encoded_private_key => nil,
    #Use Kopal::Theme#filters instead.
    #:widget_google_analytics_code,
    #:meta_something # names starting with 'meta_' are common to all, and are always
    #stored only for 'kopal_account_id' as 0. Modify validate , get_field to do so (not save_field).
  }
  
  DEPRECATED_FIELDS = {
    :example_deprecated_field => "You're using example_deprecated_field.",
  }

  DEFAULT_PASSWORD = 'secret01'

  ALL_FIELDS = FIELDS.keys + DEPRECATED_FIELDS.keys

  validates_presence_of :name
  validates_inclusion_of :name, #same in check_preference_name!()?
    :in => ALL_FIELDS.to_s,
    :unless => Proc.new { |p| p.preference_name.starts_with? TEMP_PREFERENCE_NAME_PREFIX},
    :message => "{{value}} is not in the list."
  before_validation_on_create :validates_uniqueness_of_kopal_account_id_and_preference_name

  #OPTIMIZE: Internationalise/Localise it.
  def validate
    name = self.preference_name = self.preference_name.to_s.downcase
    text = self.preference_text
    errors.add('preference_name', 'is delegated to application.') if self.class.delegated? name
    case name
    when /account_password_(hash|salt)/:
        errors.add_to_base("Password hash/salt length must be 512 bit.") unless
          text.size == 128
        errors.add_to_base("Password hash/salt must be a hexadecimal string.") unless
          valid_hexadecimal?(text)
    when "feed_real_name":
      errors.add_to_base('Real name must not be blank') if text.blank?
    when "feed_email":
      begin
        e = TMail::Address.parse(text.to_s) #nil to ''
        self.preference_text = e.address # Vi <vi@example.net> => vi@example.net
      rescue TMail::SyntaxError
        errors.add_to_base('"feed_email" is not a valid Email')
      end
    when "feed_gender":
      errors.add_to_base('Gender must be "Male" or "Female"') unless
        text =~ /^Male|Female$/ #case sensitive
    when /^feed_show_email|feed_show_gender|feed_city_has_code$/:
      errors.add_to_base('"' + name + '" must be either <tt>true</tt> or <tt>false</tt>') unless
        text =~ /^true|false$/
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

  #Also available as <tt>Kopal::ProfileUser#[]</tt>
  def self.get_field kopal_account_id, preference_name
    check_preference_name! preference_name
    get_field_without_raise kopal_account_id, preference_name
  end

  #Migration script should call this function.
  #Does not raises exception if key is not found or is deprecated. Return false then.
  def self.get_field_without_raise kopal_account_id, preference_name
    if delegated? preference_name
      m = Kopal.delegated_preference_method
      return m[:class].constantize.send m[:accessor],
        Kopal::KopalAccount.find(kopal_account_id).identifier_from_application, preference_name.to_s
    end
    s = self.find_by_kopal_account_id_and_preference_name(kopal_account_id, preference_name.to_s)
    return( s ? s.preference_text : DEFAULT_VALUE[preference_name.to_sym])
  end

  #Creates or updates as necessary and returns the saved +preference_text+.
  #Also available as <tt>Kopal::ProfileUser#[]=</tt>
  def self.save_field kopal_account_id, preference_name, preference_text
    check_preference_name! preference_name
    if delegated? preference_name
      m = Kopal.delegated_preference_method
      return m[:class].constantize.send m[:mutator],
        Kopal::KopalAccount.find(kopal_account_id).identifier_from_application, preference_name.to_s, preference_text
    end
    s = self.find_or_initialize_by_kopal_account_id_and_preference_name(kopal_account_id, preference_name)
    s.preference_text = preference_text;
    s.save!
    s.preference_text
  end

  #TODO: Write me
  def self.delete_field kopal_account_id, preference_name
  end

  #+false+ if invalid.
  #+true+ or +"deprecated"+ if valid.
  def self.preference_name_valid? name
    FIELDS.include?(name.to_sym) || (deprecated?(name) && 'deprecated')
  end

  #returns false if not, else deprecation-message if true.
  def self.deprecated? name
    return false unless DEPRECATED_FIELDS.has_key? name.to_sym
    DEPRECATED_FIELDS[name.to_sym]
  end

  def self.delegated? preference_name
    Kopal.preferences_delegated_to_application.include? preference_name.to_sym
  end

  def self.save_password kopal_account_id, password
    require 'digest'
    #need transaction?
    salt = self.save_field(kopal_account_id, 'account_password_salt', Kopal.khelper.random_hexadecimal(128))
    password = Digest::SHA512.hexdigest password + salt
    self.save_field(kopal_account_id, 'account_password_hash', password)
  end

  def self.verify_password kopal_account_id, password
    require 'digest'
    salt = self.get_field(kopal_account_id, 'account_password_salt')
    hash = self.get_field(kopal_account_id, 'account_password_hash')
    hash == Digest::SHA512.hexdigest(password + salt.to_s)
  end

private

  def validates_uniqueness_of_kopal_account_id_and_preference_name
    if self.class.
        find_by_kopal_account_id_and_preference_name self[:kopal_account_id], self[:preference_name]
      errors.add('preference_name', 'Preference name is already used.')
    end
  end

  #post-fixed(!) since raises exception.
  def self.check_preference_name! name
    return if name.starts_with? TEMP_PREFERENCE_NAME_PREFIX
    raise Kopal::KopalPreference::InvalidFieldName, 'Preference name ' + name.to_s +
      ' is not valid.' unless preference_name_valid? name
    deprecation_reason = deprecated? name
    DeprecatedMethod.here "#{name}; #{deprecation_reason}" if deprecation_reason
  end
end

