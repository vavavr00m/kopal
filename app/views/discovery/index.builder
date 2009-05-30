xml.Discovery do
  xml.KopalIdentity @profile_user.profile_identity
  xml.Name @profile_user.name
  xml.PublicKey :algorithm => 'RSA'
  xml.KopalFeedUrl @profile_user.kopal_feed_url
end