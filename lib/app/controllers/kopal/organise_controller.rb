#This controller is mainly for Administrative tasks.
class Kopal::OrganiseController < Kopal::ApplicationController
  before_filter :authorise

  def index
    redirect_to :action => :dashboard
  end

  def dashboard
    redirect_to :action => :edit_profile #for now
  end

  #TODO: Allow delegation of OpenID.
  def preference
    preference_4hackers if params[:"h@ck"] #Any interesting name with some technical meaning?
    if request.post?
    end
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
    re = Proc.new {
      redirect_to home_path(:action => 'friend')
      return
    }
    re.call if params[:identity].blank?
    friend = UserFriend.find_or_initialize_by_kopal_identity(
      normalise_url params[:identity])
    case params[:action2]
    when 'start'
      case friend.friendship_state
      when 'friend'
        flash[:highlight] = "#{u.kopal_identity} is already your friend."
        re.call
      when 'pending'
        Kopal.fetch(friend.kopal_identity.friendship_update_url('friend',
          friend.friendship_key))
        #TODO: Validations according to specs.
        friend.friendship_state = 'friend'
        friend.save!
        flash[:highlight] = "#{friend.kopal_identity} is now your friend."
        re.call
      when 'waiting'
        flash[:highlight] = "Waiting for approval from #{friend.kopal_identity}"
        re.call
      else
        begin
          r = Kopal.fetch friend.kopal_identity.discovery_url
        rescue Kopal::Antenna::FetchingError => e
          flash[:notice] = "Error making discovery on #{friend.kopal_identity}"
          re.call
        end
        flash[:notice] = "Invalid Kopal Connect URI #{r.response_uri}" and re.call unless
          r.kopal_connect_discovery?
        friend.public_key = r.kopal_connect_discovery.elements["PublicKey"].text
        begin
          friend.kopal_feed = Kopal::Feed.new friend.kopal_identity.feed_url
        rescue Kopal::Antenna::FetchingError => e
          flash[:notice] = "Error fetching Kopal Feed for #{friend.kopal_identity}"
          re.call
        end
        friend.friendship_state = 'waiting'
        friend.assign_key!
        friend.save!
        r = Kopal.fetch(friend.kopal_identity.friendship_request_url)
        if r.kopal_connect_discovery?
          state = r.body_xml.root.elements["FriendshipState"].attributes["state"]
          re.call("FriendshipState has invalid value.") unless
            ['pending', 'friend', 'rejected'].include? state
          if state == 'rejected'
            friend.destroy
            flash[:notice] = "Friendship declined by #{friend.kopal_identity}"
            re.call
          end
          friend.state = if state == 'pending' then 'waiting' else 'friend' end
          friend.save!
          flash[:highlight] = "Friendship state of #{friend.kopal_identity} is now #{friend.state}"
          re.call
        end
      end
    when 'delete'
      friend.destroy
      Kopal.fetch(friend.kopal_identity.friendship_update_url 'rejected',
        friend.friendship_key)
      flash[:highlight] = "Deleted friend #{friend.kopal_identity}"
      re.call
    end
    re.call
  end

  def password
    if request.post?
      flash.now[:notice] = "Password is blank." and return if params[:password].blank?
      flash.now[:notice] = "Passwords do not match." and return unless
        params[:password] == params[:password_confirmation]
      Kopal[:account_password] = params[:password]
      flash[:highlight] = "Password changed!"
      redirect_to root_path
    end
  end

private

  #Advanced preferences.
  def preference_4hackers
    
  end
end
