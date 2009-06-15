module Kopal
  
  class KopalError < StandardError; end;
  class KopalIdentityInvalid < KopalError; end;
  class KopalXmlError < KopalError; end;
  class KopalConnectInvalid < KopalXmlError; end;
  class KopalFeedInvalid < KopalXmlError; end;
end
