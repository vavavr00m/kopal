module Kopal
  
  class KopalError < StandardError; end;
  class KopalIdentityInvalid < KopalError; end;
  class KopalXmlError < KopalError; end;
  class KopalConnectInvalid < KopalXmlError; end;
  class KopalFeedInvalid < KopalXmlError; end;

  KOPAL_ERROR_ID = {
    0x0000 => "Generic Kopal error.",
    0x1000 => "Kopal Connect error.",
    0x1100 => "Kopal Connect discovery error.",
    0x1101 => "Invalid public key.",
    0x1200 => "Kopal Connect friendship error.",
    0x1201 => "Duplicate friendship request.",
    0x1202 => "Invalid friendship state {state}.",
    0x1203 => "Unknown friendship state {state}.",
    0x1204 => "Invalid friendship key.",
    0x1205 => "Unknown friend Kopal Identity {identity}.",
    0x1210 => "Method not supported.",
    0x1211 => "Identification required.",
    0x1220 => "Can not update friendship state.",
    0x2000 => "Kopal Feed error."
  }
end
