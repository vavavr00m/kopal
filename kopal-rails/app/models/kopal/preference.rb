#Preferences for Application. Preferences for profiles, accounts, users and feed go directly within same models.
class Kopal::Preference < Kopal::Model

  DEFAULT_PASSWORD = 'secret01'
  
  field :meta_upgrade_last_check, :type => Datetime

end

