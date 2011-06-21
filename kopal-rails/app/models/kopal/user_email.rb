class Kopal::UserEmail < Kopal::Model
  
  field :string
  
  referenced_in :user, :class_name => "Kopal::User"
  
  validates :string, :presence => true, :uniqueness => true
  validates_each :string do |record, attr, value|
    begin 
      record[attr.to_sym] = Mail::Address.new(value).address
    rescue Mail::Field::ParseError
      record.errors.add attr, :invalid
    end
  end
  
  def to_s
    string.to_s
  end
  
end