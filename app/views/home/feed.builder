xml.instruct!
xml.comment! "DTD at http://kopal.googlecode.com/svn/static/DTD/kopal-feed.r1.0.dtd"
xml.KopalFeed :revision => Kopal::FEED_PROTOCOL_REVISION,
  :platform => Kopal::PLATFORM do
  xml.Identity do
    xml.Homepage @profile_user.profile_url
    xml.KopalIdentity @profile_user.kopal_identity
    xml.RealName @profile_user.feed.real_name
    xml.Aliases do
      @profile_user.feed.aliases.each {|a|
        if @profile_user.feed.name == a
          xml.Alias a, :preferred_calling_name => true
        else
          xml.Alias a
        end
      }
    end
    xml.Description @profile_user.feed.description unless
      @profile_user.feed.description.blank?
    xml.Image @profile_user.image_path, :type => :url
    xml.Gender @profile_user.feed.gender unless @profile_user.feed.gender.blank?
    xml.Email @profile_user.feed.email
    xml.BirthTime @profile_user.feed.birth_time_string
    xml.Address do
      xml.Country do
        xml.Living @profile_user.feed.country_living_code
      end
      if @profile_user.feed.city_has_code?
        xml.City @profile_user.feed.city_code, :standard => 'un/locode'
      else
        xml.City @profile_user.feed.city_name
      end
    end
  end
end