#Visitor
#Maintain only one instance accessible from Kopal.visiting_user
class Kopal::VisitingUser < Kopal::KopalUser

  attr_reader :kopal_identity
  
  def initialize kopal_identity = nil, homepage = nil
    if kopal_identity
      @kopal_identity = (kopal_identity.is_a?(Kopal::Identity) ? kopal_identity :
          Kopal::Identity.new(kopal_identity))
    end
    @homepage = homepage
  end

  #If the current visitor is profile user herself? Or in other words,
  #should we enable administrative tasks?
  def homepage?
    @homepage
  end

  #Is the visitor recognised and has a valid Kopal Identity?
  #+Not+ same as <tt>Kopal::ProfileUser#signed?</tt>
  def signed?
    !!kopal_identity
  end
end
