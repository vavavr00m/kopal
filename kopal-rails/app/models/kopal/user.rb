#Users who manage Kopal profiles via an account.
#LATER: It should be possible that the parent application provides
#users and permissions to Kopal application.
class Kopal::User < Kopal::Model

  field :full_name
  field :emails, :type => Array
  field :openids, :type => Array
  field :password_hash, :type => String
  field :password_salt, :type => String
  
  attr_accessor :password, :password_confirmation

  embeds_many :preferences
  validates_presence_of :email
  
  #The first email is always the default one.
  def email
    emails.first
  end
  
  def calculate_password_hash
    self.password_hash = SHA1
  end
  
  def generate_random_salt
    self.password_salt = ActiveRecord::SecureRandom.hex 
  end
end