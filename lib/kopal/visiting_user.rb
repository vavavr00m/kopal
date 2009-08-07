#Visitor
class Kopal::VisitingUser < Kopal::KopalUser

  attr_reader :kopal_identity
  def initialize kopal_identity = nil
    if kopal_identity
      @kopal_identity = (kopal_identity.is_a?(Kopal::Identity) ? kopal_identity :
          Kopal::Indetity.new(kopal_identity))
    end
  end

  def has_kopal_identity?
    !!kopal_identity
  end

  alias_method :"known?", :"has_kopal_identity?"
end
