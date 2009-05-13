#Just a nice wrapper around KopalPreference
class KopalPref
  def self.method_missing(method, *args)
    if method =~ /=$/
      k = KopalPreference.find_or_initialize_by_preference_name(method.gsub('=', ''))
      k.preference_text = args[0].to_s
      k.save!
    else
      k = KopalPreference.find_by_preference_name(method)
      return k.preference_text if k
      return nil
    end
  end
end

