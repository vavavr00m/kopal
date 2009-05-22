xml.instruct!
xml.Kopal :revision => Kopal::DISCOVERY_PROTOCOL_REVISION,
  :platform => Kopal::PLATFORM do |xm|
    xm << yield
end
