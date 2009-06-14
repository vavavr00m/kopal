module Kopal
  
  class KopalError < StandardError; end;
  class InvalidKopalIdentity < KopalError; end;
  class KopalXmlError < KopalError; end;
  class InvalidKopalConnect < KopalXmlError; end;
  class InvalidKopalFeed < KopalXmlError; end;
end
