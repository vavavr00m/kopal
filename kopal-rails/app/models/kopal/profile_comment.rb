require 'mail' #FIXME: uninitialized constant Mail
class Kopal::ProfileComment < Kopal::Model
  DUPLICATE_TIME = 2.minutes #Time within which a duplicate comment can not be saved.

  field :full_name
  field :email
  field :website_address
  field :comment_text
  
  referenced_in :profile, :class_name => "Kopal::Profile"
  referenced_in :user, :class_name => "Kopal::User"

  with_options :if => Proc.new { |record| record.user.blank? } do |x|
    x.validates :full_name, :presence => true
    x.validates :email, :presence => true
    x.validates_each :email do |record, attr, value| #Duplicated in Kopal::UserEmail
      begin 
        record[attr.to_sym] = ::Mail::Address.new(value).address
      rescue ::Mail::Field::ParseError
        record.errors.add attr, :invalid
      end
    end
    x.validates_each :website_address do |record, attr, value|
      begin
        if record.send(attr).present?
          record[attr.to_sym] = normalise_url record[attr.to_sym]
        end
      rescue URI::InvalidURIError
        record.errors.add(attr, "has invalid syntax")
      end
    end
  end
  validates :comment_text, :presence => true
  
  def validate
    if duplicate_comment?
      errors.add_to_base("Same comment was submitted too recently by you.")
    end
  end
  
  #TODO: Comment is duplicate when content is same and generated from same origin.
  def duplicate_comment?
    new_record? && if user.present?
      self.class.where(:user_id => user.id)
    else
      self.class.where(:email => email)
    end.where(:comment_text => comment_text, :created_at.lt => DUPLICATED_TIME.ago).present?
  end
end
