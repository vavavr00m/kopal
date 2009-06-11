xml.instruct!
xml.comment! "DTD at http://kopal.googlecode.com/svn/static/DTD/kopal.r1.0.dtd"
xml.Kopal :revision => Kopal::DISCOVERY_PROTOCOL_REVISION,
  :platform => Kopal::PLATFORM do |xm|
    xm << yield
end
