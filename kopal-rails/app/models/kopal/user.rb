#Users who manage Kopal profiles via an account.
#LATER: It should be possible that the parent application provides
#users and permissions to Kopal application.
class Kopal::User < Kopal::Model

  field :full_name
  field :password_hash, :type => String
  field :password_salt, :type => String
  
  references_many :emails, :class_name => "Kopal::UserEmail", :dependent => :destroy, :autosave => true
  #references_many :openids, :class_name => "Kopal::UserOpenid", :dependent => :destroy
  
  attr_accessor :password, :password_confirmation

  references_many :preferences
  
  validates_presence_of :password_hash, :if => :using_password?
  validates_presence_of :password_salt, :if => :using_password?
  
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