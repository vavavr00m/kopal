#Users who manage Kopal profiles via an account.
#LATER: It should be possible that the parent application provides
#users and permissions to Kopal application.
class Kopal::User < Kopal::Model

  field :full_name
  field :password_hash, :type => String
  field :password_salt, :type => String
  
  #preferences
  field :authentication_method, :type => String
  
  references_many :emails, :class_name => "Kopal::UserEmail", :dependent => :destroy, :autosave => true
  #references_many :openids, :class_name => "Kopal::UserOpenid", :dependent => :destroy
  
  attr_accessor :password, :password_confirmation

  validates :full_name, :presence => true, :length => {:maximum => 256 }
  validates_each :email do |record, attr, value|
    begin 
      record[attr.to_sym] = Mail::Address.new(value).address
    rescue Mail::Field::ParseError
      record.errors.add attr, :invalid
    end
  end
  with_options :if => :using_password? do |x|
    validates :password_hash, :password_salt, :length => {:in => 512..512}
  end
  
  class << self
    
    #@return [User]
    def authenticate options
      #TODO: check preferences.authentication_method
      options.to_options!.assert_valid_keys :email, :password, :openid
      user = Kopal::UserEmail.where(:string => options[:email]).first.try :user
      if user && user.valid_password?(options[:password])
        return user
      end
      return false
    end
    
    def calculate_password_hash salt, password
      Digest::SHA512.hexdigest(salt + password)
    end
    
    def generate_random_salt
      ActiveSupport::SecureRandom.hex 512/8
    end
    
  end
  
  def to_s
    full_name.to_s
  end
  
  #The first email is always the default one.
  def email
    emails.try(:first).try(:string)
  end
  
  def using_password?
    #preferences.authentication_method == :password
    true #for now
  end
  
  def password= value
    @password = value
    assign_random_password_salt
    self.password_hash = self.class.calculate_password_hash password_salt, password
  end
  
  def valid_password? password
    password_hash == self.class.calculate_password_hash(password_salt, password)
  end
  
  def assign_random_password_salt
    self.password_salt = self.class.generate_random_salt
  end
  
end