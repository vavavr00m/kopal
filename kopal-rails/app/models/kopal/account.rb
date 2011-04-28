#An account is a mapping of user to a profile.
#A Kopal::User has an Kopal::Account on a Kopal::Profile.
class Kopal::Account < Kopal::Model
  
  #The only difference bet^n superuser and normal account
  #is that superuser account can create/delete other accounts.
  #(for now) only two account types - superuser, normal
  field :superuser, :type => Boolean

  referenced_in :profile, :inverse_of => :accounts, :class_name => "Kopal::Profile"
  references_one :user, :class_name => "Kopal::User"
  
  scope :superusers, where(:superuser => true)
  
end
