module Kopal
  
  class KopalError < StandardError; end;
  class InvalidKopalIdentity < KopalError; end;
  class KopalXmlError < KopalError; end;
  class InvalidKopalConnect < KopalXmlError; end;
  class InvalidKopalFeed < KopalXmlError; end;
  
  class KopalError
    KOPAL_ERROR_ID = {
      0000 => "General Error",
      1000 => "Kopal Discovery Error",
      2000 => "Kopal Feed Error",
      2001 => "Kopal Feed Invalid Revision",
      2100 => "Kopal Feed Identity Error",
      2101 => "Kopal Feed Identity Invalid Homepage",
      2102 => "Kopal Feed Identity Invalid RealName"
    }
    
    attr_accessor :error_id
    
    def initialize error_id = 0000
      @error_id = error_id
    end
  end
      
end
