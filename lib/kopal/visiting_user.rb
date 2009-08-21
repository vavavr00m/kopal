#Visitor
#Maintain only one instance accessible from Kopal.visiting_user
class Kopal::VisitingUser < Kopal::KopalUser

  attr_reader :kopal_identity
  def initialize kopal_identity = nil
    if kopal_identity
      @kopal_identity = (kopal_identity.is_a?(Kopal::Identity) ? kopal_identity :
          Kopal::Indetity.new(kopal_identity))
    end
  end

  #Alias for Kopal::ProfileUser#signed?
  def self?
    Kopal.profile_user.signed?
  end

  #Is the visitor recognised and has a valid Kopal Identity?
  def signed?
    !!kopal_identity
  end
end
