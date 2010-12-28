xml.instruct!
xml.tag!("xrds:XRDS", :"xmlns:openid" => "http://openid.net/xmlns/1.0", 
  :"xmlns:xrds" => "xri://$xrds", :"xmlns" => "xri://$xrd*($v*2.0)") do

  xml.XRD do
    xml.Service do
      xml.Type "http://specs.openid.net/auth/2.0/signon"
      xml.LocalID @profile_user.kopal_identity.to_s
    end
  end
end