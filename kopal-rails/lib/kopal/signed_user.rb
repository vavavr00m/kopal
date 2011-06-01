#A SignedUser is a user or a profile that is currently signed-in.
#It can be a local user, or a signed-in OpenID / Kopal Identity.
#
#TODO: For user signed-in with OpenID/Kopal Identity store full/first/last name and email for views to display.
class Kopal::SignedUser
  
  def initialize options
    options.to_options!.assert_valid_keys :user_id, :openid_identifier, :kopal_identity
    @kopal_identity = Kopal::Identity.new options[:kopal_identity] if options[:kopal_identity].present?
    if options[:user_id].present?
      @user = Kopal::User.find options[:user_id]
    elsif options[:openid_identifier].present?
      @openid_identifier = options[:openid_identifier]
      @kopal_identity = Kopal::Identity.new @openid_identifier #for now assume the signed-in OpenID is also a Kopal Identity.
    end
  end
  
  def to_s
    foreign_visitor? ? kopal_identity.to_s : user.to_s
  end
  
  #An "foreign visitor" is a user who is signed-in using third-party OpenID and doesn't has
  #User record on this site.
  def foreign_visitor?
    not user
  end
  alias foreigner? foreign_visitor?
  
  def kopal_identity
    @kopal_identity
  end
  
  def user
    @user
  end
  
end