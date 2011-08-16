#Users who manage Kopal profiles via an account.
#LATER: It should be possible that the parent application provides
#users and permissions to Kopal application.
#
#TODO: Everytime a user signs-in using OpenID for first time, create a User account.
#TODO: If someone just enters their email, website and name while giving a comment, register it as a User record.
#
#TODO: We must integrate this model with Kopal::Profile and "profile" and "user" can not be two separate identities (for simplicity, at least for now). 
#See https://code.google.com/p/kopal/wiki/Authentication
class Kopal::User < Kopal::Model

  field :full_name
  field :password_hash, :type => String
  field :password_salt, :type => String
  
  #preferences
  field :authentication_method, :type => String, :default => "any"
  
  references_many :emails, :class_name => "Kopal::UserEmail", :dependent => :destroy, :autosave => true
  references_many :openids, :class_name => "Kopal::UserOpenid", :dependent => :destroy, :autosave => true
  
  attr_accessor :password, :password_confirmation

  validates :full_name, :presence => true, :length => {:maximum => 256 }
  with_options :if => :using_password? do |x|
    validates :password_hash, :password_salt, :length => {:in => 512..512}
  end
  
  class << self
    
    #Authenticate by email/password
    #@return [User]
    def authenticate options
      #TODO: check preferences.authentication_method
      options.to_options!.assert_valid_keys :email, :password
      user = Kopal::UserEmail.where(:string => options[:email]).first.try :user
      if user && user.valid_password?(options[:password])
        return user
      end
      return false
    end
    
    def find_or_create_by_openid identifier, options = {}
      raise "OpenID signin not implemented."
      Kopal::UserOpenid.where(:string => identifier).first.try(:user) ||
        create!(:full_name => options.full_name, :authentication_method => 'openid', :openids => [:string => identifier])
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
  
  def authentication_method
    ActiveSupport::StringInquirer.new self[:authentication_method].to_s
  end
  
  def using_password?
    authentication_method.any? or authentication_method.password?
  end
  
  def using_openid?
    authentication_method.any? or authentication_method.openid?
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