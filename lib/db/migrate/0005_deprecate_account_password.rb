class DeprecateAccountPassword < ActiveRecord::Migration
  
  KP = Kopal::KopalPreference
    
  def self.up
    if(Kopal[:account_password_hash].nil?)
      password = KP.get_field_without_raise('account_password')
      KP.save_password(password)
    end
    KP.delete_field 'account_password'
  end
  
  def self.down
    #irreversible-migration instead?, since we lose password.
    KP.delete_field('account_password_hash')
    KP.delete_field('account_password_salt')
  end
end
