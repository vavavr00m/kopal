class Kopal::UserEmail < Kopal::Model
  
  field :string
  
  referenced_in :user, :class_name => "Kopal::User"
  
  validates_presence_of :string
  validates_uniqueness_of :string
  
  def to_s
    string.to_s
  end
  
end