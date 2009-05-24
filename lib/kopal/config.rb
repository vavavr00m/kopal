#== Kopal Configurations
#You may define them in <tt>environment.rb</tt> as
#<tt>Kopal.config.config_name = 'value'</tt>
#
#=== Configuration Options
#* authentication_method
#* Write me
class Kopal::Config

  attr_reader :authentication_method,
    :account_password_hash_function
  attr_accessor :account_password

  def initialize
    assign_defaults!
  end

  #Pass a string value for pre-defined authentication methods
  #[<tt>simple</tt>] - Just using a password (See account_password=).
  #[<tt>openid</tt>] - Using Open-ID (to-implement).
  #If a Symbol is passed, it is considered to be an instance method of
  #ApplicationController, responsible for authentication. If the value is
  #<tt>true</tt>, authentication is considered success, otherwise the method should
  #return <tt>false</tt> or <tt>nil</tt> and should redirect to the Sign-in page.
  def authentication_method= value
    value.downcase!
    string_values = ['simple']
    raise ArgumentError, '"' + value + '" is not a recognised authentication ' +
      'method' if value.is_a? String and !string_values.include? value
    @authentication_method = value
  end

  #Required only if authentication_method is <tt>simple</tt>.
  def account_password_hash_function= value
    value.downcase!
    values = ['plain', 'md5', 'sha1', 'sha512']
    raise ArgumentError, '"' + value + '" is not a recognised hash function. ' +
      'Recognised hash functions are ' + values.to_sentence unless
      values.include? value
    @account_password_hash_function = value
  end

private

  def assign_defaults!
    @authentication_method = 'simple'
    @account_password_hash_function = 'plain'
  end
end