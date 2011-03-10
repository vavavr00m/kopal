#Users who manage Kopal profiles via an account.
#LATER: It should be possible that the parent application provides
#users and permissions to Kopal application.
class Kopal::User < Kopal::Model

  field :full_name
  field :emails, :type => Array
  field :openids, :type => Array

  embeds_many :preferences
end