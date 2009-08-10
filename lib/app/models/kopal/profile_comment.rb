#Model fields
#  email, string, not null
#  website_address, string, length => 255
#  is_kopal_identity, boolean
#  comment_text, text
#Model indices
#  none
class Kopal::ProfileComment < Kopal::KopalModel

  DUPLICATE_TIME = 2.minutes #Time within which a duplicate comment can not be saved.

  #Name and email must be present if Website address is not a verified Kopal Identity.
  validates_presence_of :name, :email, :unless => Proc.new { |i| i.kopal_identity?}
  #Website address must be present (of course) if is_kopal_identity is true
  validates_presence_of :website_address, :if => Proc.new {|i| i.kopal_identity?}
  validates_presence_of :comment_text

  def validate
    begin
      unless self[:email].blank?
        #TODO: Create a helper around tmail parser which checks if "@" is present
        #throw Kopal::EmailSyntaxInvalid elsewise.
        #"bad-bad-email!!" is good for TMail.
        self[:email] = TMail::Address.parse(self[:email]).address
      end
    rescue TMail::SyntaxError
      errors.add(:email, "has invalid syntax.")
    end
    begin
      unless self[:website_address].blank?
        self[:website_address] = normalise_url self[:website_address]
      end
    rescue URI::InvalidURIError
      errors.add(:website_address, "has invalid syntax.")
    end
    if duplicate_comment?
      errors.add_to_base("Same comment was submitted too recently by you.")
    end
  end

  def duplicate_comment?
    u = self.class.find_by_comment_text(self[:comment_text],
      :conditions => ['created_at > ?', DUPLICATE_TIME.ago])
  end

  def from_kopal_identity
    Kopal::Identity.new self[:website_address] if kopal_identity?
  end

  def is_kopal_identity
    if [0, nil].include? self[:is_kopal_identity]
      return false
    end
    return true
  end

  def is_kopal_identity= value
    self[:is_kopal_identity] = if [0, false, nil].include? value
      0
    else
      1
    end
  end

  #true if the commenting user has been verfied to carry a valid Kopal Identity.
  #Alias for is_kopal_identity
  def kopal_identity?
    is_kopal_identity
  end
end