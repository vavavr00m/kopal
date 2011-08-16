class Kopal::UserOpenid < Kopal::Model
  
  field :string
  
  referenced_in :user, :class_name => "Kopal::User"
end