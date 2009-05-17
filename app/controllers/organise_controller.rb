class OrganiseController < ApplicationController
  before_filter :authorise

  def index
    redirect_to :action => :dashboard
  end

  def dashboard
    redirect_to :action => :edit_profile #for now
  end

  #OPTIMIZE: Auto-completion for City field.
  #OPTIMIZE: Real-time updation in Preferred calling name with change in name/aliases.
  def edit_profile
    if request.post?
      #OPTIMIZE: presently, one database save per field. Take it all in one go.
      begin
        [ :feed_name,
          :feed_aliases,
          :preferred_calling_name,
          :feed_description,
          :feed_gender,
          :birth_time_pref,
          :feed_country_living_code
        ].each { |e|
            Kopal[e] = params[e]
        }
      rescue ActiveRecord::RecordInvalid => e
        flash.now[:notice] = e.message
        return
      end
      #better method exists?
      Kopal[:city_has_code] = "no"
      city_list.each { |k,v| #60,000 rounds in worst case!!
        if v.to_s.downcase == params[:city].downcase
          Kopal[:feed_city] = k.to_s #From symbol
          Kopal[:city_has_code] = "yes"
          break
        end
      }
      Kopal[:feed_city] = params[:city] if Kopal[:city_has_code] == "no"
    end
  end
end
