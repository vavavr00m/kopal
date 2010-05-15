profile_user = Kopal::ProfileUser.new 0

Designer.profile_friend('test_host', :class => 'Kopal::ProfileFriend') do |record|
  record.kopal_account_id = profile_user.account.id
  record.friend_kopal_identity = 'http://test.host/profile/'
  record.friendship_state = 'waiting'
  record.friend_public_key = profile_user.public_key.to_pem
  record.friend_kopal_feed = "<KopalFeed revision=\"0.1.draft\"><Identity>" +
      "<Homepage>http://example.net/</Homepage><RealName>Test User</RealName>" +
      "</Identity></KopalFeed>"
  record.assign_key!
end