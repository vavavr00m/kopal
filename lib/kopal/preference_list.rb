class Kopal::PreferenceList

  #Only these values can be stored in the <tt>preference_name</tt> field. (extreme programming?).
  #It is up to Controller to choose a default value for fields.
  FIELDS = [
    :authentication_method,
    :account_password_hash, #SHA-512 password hash.
    :account_password_salt, #512-bit salt.
    :user_status_message,
    :feed_real_name, #Name of the user
    :feed_aliases, #Aliases of the user separated by "\n"
    :feed_preferred_calling_name,
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
    :example_deprecated_field => "You're using example_deprecated_field.",
    :account_password => "Use :account_password_hash instead."
  }
  DEFAULT_VALUE = {
    :authentication_method => 'simple',
    :feed_show_gender => 'yes'
  }

  DEFAULT_PASSWORD = 'secret01'
  
end