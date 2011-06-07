class Kopal::FeedData < Kopal::Model
  
  field :real_name, :type => String
  field :name_aliases, :type => Array
  field :preferred_calling_name, :type => String
  field :profile_description, :type => String
  field :email, :type => String
  field :sex, :type => String, :default => ''
  field :birth_time, :type => DateTime
  field :country_living_code, :type => String
  field :country_citizenship_codes, :type => Array
  field :city_code_or_name, :type => String
  field :city_has_code, :type => Boolean
  
  #preferences
  field :show_email, :type => Boolean
  field :show_sex, :type => Boolean
  field :birth_time_display_format, :type => String
  
  validates :real_name, :presence => true
  validates :sex, :inclusion => { :in => ['Male', 'Female', ''] }
  validates :birth_time_display_format, :inclusion => {:in => ['ymd', 'y', 'md', 'false']}
  
  def city
    #city_has_code? ? get name : city_code_or_name
  end
  
  def preferred_calling_name= value
    name_aliases = (name_aliases.push(value).uniq - real_name)
    self[:preferred_calling_name] = value
  end
  
  def country_citizenship_codes
    self[:country_citizenship_codes].or_on_blank [country_living_code]
  end
  
  def to_feed_hash
    {
      :real_name => real_name,
      :name_aliases => name_aliases,
      :preferred_calling_name => preferred_calling_name,
      :profile_description => profile_description,
      :email => email,
      :sex => sex,
      :birth_time => birth_time,
      :country_living => country_living_code,
      :country_citizenships => country_citizenship_codes,
    }
  end
  
  def to_kopal_feed
    Kopal::Feed.new to_feed_hash
  end
end