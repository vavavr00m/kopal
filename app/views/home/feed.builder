xml.instruct!
xml.comment! "DTD at http://kopal.googlecode.com/svn/static/DTD/kopal-feed.r1.0.dtd"
xml.KopalFeed :revision => Kopal::FEED_PROTOCOL_REVISION,
  :platform => Kopal::PLATFORM do
  xml.Identity do
    xml.Homepage @profile_user.profile_url
    xml.KopalIdentity @profile_user.kopal_identity
    xml.RealName @profile_user.real_name
    xml.Aliases do
      @profile_user.aliases.each {|a|
        if @profile_user.name == a
          xml.Alias a, :preferred_calling_name => true
        else
          xml.Alias a
        end
      }
    end
    xml.Description @profile_user.description
    xml.Image @profile_user.image_path, :type => :url
    xml.Gender @profile_user.gender
    xml.Email @profile_user.email
    xml.BirthTime @profile_user.birth_time
    xml.Address do
      xml.Country do
        xml.Living @profile_user.country_living_code
      end
      if @profile_user.city_has_code?
        xml.City @profile_user.city_code, :standard => 'un/locode'
      else
        xml.City @profile_user.city
      end
    end
  end
end