xml.Discovery do
  xml.KopalIdentity @profile_user.profile_identity
  xml.Name @profile_user.name
  xml.PublicKey @profile_user.public_key.to_pem, :algorithm => 'PKCS#1'
  xml.KopalFeedUrl @profile_user.kopal_feed_url
end