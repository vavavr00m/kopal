#Holds all the data of user too, since there is only one user, No need for UserAccount model.
class KopalPreference < ActiveRecord::Base
  set_table_name :kopal_preference
  serialize :preference_text

  #It is up to Controller to choose a default value for enumerated fields ex: <tt>:show_email</tt>
  FIELDS = [
    :feed_name, #Name of the user
    :feed_aliases, #Aliases of the user separated by "\n"
    :preferred_calling_name,
    :feed_description, #Description of the user
    :feed_email, #Email of user.
    :show_email, #Only <tt>yes</tt> or <tt>no</tt> downcase.
    :feed_gender, #Gender of the user, must be only <tt>male</tt> or <tt>female</tt> downcase.
    :show_gender, #must be only <tt>yes</tt> or <tt>no</tt> downcase.
    :feed_birth_time, #Date of birth of user. Must be an instance of DateTime
    :birth_time_pref, #Value must be one of <tt>ymd</tt> <tt>y</tt> <tt>md</tt>
      #or <tt>nothing</tt>. <tt>y, m, d</tt> stand for <tt>year, month, date</tt> resp.
    :feed_country_living_code, #Code for living country.
    :feed_city, #Name of the city or its code. Determined by <tt>city_has_code</tt>
    :city_has_code #Must be either <tt>yes</tt> or <tt>no</tt> downcase.
  ]
  DEPRECATED_FIELDS = {
    #:deprecated_field => "message"
  }
  validates_presence_of :preference_name
  validates_uniqueness_of :preference_name
  validates_inclusion_of :preference_name,
    :in => (FIELDS.dup.concat(DEPRECATED_FIELDS.keys)).map { |k| k.to_s },
    :message => "{{value}} is not in the list."

  #OPTIMIZE: Internationalise/Localise it.
  def validate
    self.preference_name = self.preference_name.to_s.downcase
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
      errors.add_to_base('Gender must be "male" or "female"') unless
        text =~ /^male|female$/ #case sensitive
    when /^show_email|show_gender|city_has_code$/:
      errors.add_to_base('"' + name + '" must be either <tt>yes</tt> or <tt>no</tt>') unless
        text =~ /^yes|no$/
    when "feed_birth_time":
      errors.add_to_base('"feed_birth_time" must be an instance of DateTime') unless
        text.is_a? DateTime
    when "birth_time_pref":
      errors.add_to_base('"birth_time_pref" must be one of "y", "ymd", "md", "nothing".') unless
        text =~ /^ymd|y|md|nothing$/
    when "feed_country_living_code":
      errors.add_to_base('Country code must be of length 2 in upper-case.') unless
        text =~ /^[A-Z]{2}$/
    end
  end

  #See also Kopal[]
  def self.get_field name
    deprecated? name
    s = self.find_by_preference_name(name)
    return s.preference_text if s
  end

  #See also Kopal[]=
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
    DeprecatedMethod.here DEPRECATED_FIELDS[name.to_sym] if
      DEPRECATED_FIELDS.has_key? name.to_sym
  end
end

