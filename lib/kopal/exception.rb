module Kopal
  
  class KopalError < StandardError; end;
  class InvalidKopalIdentity < KopalError; end;
  class KopalXmlError < KopalError; end;
end
