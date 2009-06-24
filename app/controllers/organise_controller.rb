#This controller is mainly for Administrative tasks.
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
        [ :feed_real_name,
          :feed_aliases,
          :feed_preferred_calling_name,
          :user_status_message,
          :feed_description,
          :feed_gender,
          :feed_birth_time_pref,
          :feed_email,
          :feed_show_email,
          :feed_country_living_code
        ].each { |e|
            Kopal[e] = params[e]
        }
      rescue ActiveRecord::RecordInvalid => e
        flash.now[:notice] = e.message
        return
      end
      Kopal[:feed_birth_time] = DateTime.new(params[:feed_birth_time]['(1i)'].to_i,
        params[:feed_birth_time]['(2i)'].to_i, params[:feed_birth_time]['(3i)'].to_i)
      #better method exists?
      #{}.index or {}.rassoc(Ruby 1.9), but we need a case insenstive search!
      #Create new method city_list_downcased and use like this?
      #<tt>city_list_downcased.index params[:feed_city].downcase</tt>
      Kopal[:feed_city_has_code] = "no"
      city_list.each { |k,v| #60,000 rounds in worst case!!
        if v.to_s.downcase == params[:feed_city].downcase
          Kopal[:feed_city] = k.to_s #From symbol
          Kopal[:feed_city_has_code] = "yes"
          break
        end
      }
      Kopal[:feed_city] = params[:feed_city] if Kopal[:feed_city_has_code] == "no"
    end
  end

  def friend
    re = Proc.new { |message|
      flash[:notice] = message
      redirect_to home_path(:action => 'friend')
      return
    }
    re.call("Identity not defined.") unless
    u = UserFriend.find_or_initialize_by_kopal_identity(params[:identity])
    case params[:action2]
    when 'start'
      r = Kopal.fetch(u.kopal_identity.friendship_request_url)
      if r.kopal_discovery?
        state = r.body_xml.root.elements["FriendshipState"].attributes["state"]
        re.call("FriendshipState has invalid value.") unless ['pending', 'friend'].include? state
        u.state = if state == 'pending' then 'waiting' else 'friend' end
        if u.new_record?
          u.kopal_feed = Kopal::Feed.new u.kopal_identity.feed_url
        end
        u.save!
        flash[:highlight] = "Friendship state changed successfully"
      end
    when 'delete'
      u.destroy
      r = Kopal.fetch(u.kopal_identity.friendship_rejection_url)
      flash[:highlight] = "Deleted friend #{u.kopal_identity}"
    end
    redirect_to home_path(:action => 'friend')
  end
end
