#This controller is mainly for Administrative tasks.
class Kopal::OrganiseController < Kopal::ApplicationController
  before_filter :authorise

  def index
    redirect_to :action => :dashboard
  end

  def dashboard
    redirect_to :action => :edit_identity #for now
  end

  #TODO: Allow delegation of OpenID.
  def preference
    preference_4hackers if params[:"h@ck"] #Any interesting name with some technical meaning?
    if request.post?
    end
  end

  #Web-based API for Kopal::KopalPreference
  #Pass GET parameters +key+ and +value+ as preference name and new value.
  #
  def config
    if params[:key].blank?
      flash.now[:notice] = "Key can not be empty."
      return
    end
    @key = params[:key].to_s.downcase.to_sym
    if message = Kopal::KopalPreference.deprecated?(@key)
      flash.now[:notice] = "<code>#{@key}</code> is deprecated. #{message}"
      return
    end
    unless Kopal::KopalPreference.preference_name_valid? @key
      flash.now[:notice] = "Invalid key <code>#{@key}</code>."
      return
    end
    if request.post?
      begin
        @profile_user[@key] = params[:value]
      rescue ActiveRecord::RecordInvalid => e
        flash.now[:notice] = "<b>ERROR:</b> #{e.message}"
        return
      end
      flash[:highlight] = "Key <code>#{@key}</code> set to <code>#{@profile_user[@key]}</code>."
      redirect_to @kopal_route.home
      return
    else
      @present_value = @profile_user[@key]
    end
    unless @present_value
      render 'config', :status => 400 #doesn't work
    end
  end

  def backup
    if request.post?
      send_data Kopal::Database.backup, :content_type => :xml #or 'application/xml'
      return
    end
    #render A form only with a submit button "Continue"
  end

  #OPTIMIZE: Auto-completion for City field.
  #OPTIMIZE: Real-time updation in Preferred calling name with change in name/aliases.
  def edit_identity
    if request.post?
      #OPTIMIZE: presently, one database save per field. Take it all in one go.
      begin
        [ :feed_real_name,
          :feed_aliases,
          :feed_preferred_calling_name,
          :profile_status_message,
          :feed_description,
          :feed_gender,
          :feed_birth_time_pref,
          :feed_email,
          :feed_show_email,
          :feed_country_living_code
        ].each { |e|
          @profile_user[e] = params[e]
        }
      rescue ActiveRecord::RecordInvalid => e
        flash.now[:notice] = e.message
        return
      end

      @profile_user[:feed_birth_time] = DateTime.new(params[:feed_birth_time]['(1i)'].to_i,
        params[:feed_birth_time]['(2i)'].to_i, params[:feed_birth_time]['(3i)'].to_i)
      #better method exists?
      #{}.index or {}.rassoc(Ruby 1.9), but we need a case insenstive search!
      #Create new method city_list_downcased and use like this?
      #<tt>city_list_downcased.index params[:feed_city].downcase</tt>
      @profile_user[:feed_city_has_code] = "no"
      city_list.each { |k,v| #60,000 rounds in worst case!!
        if v.to_s.downcase == params[:feed_city].downcase
          @profile_user[:feed_city] = k.to_s #From symbol
          @profile_user[:feed_city_has_code] = "yes"
          break
        end
      }
      @profile_user[:feed_city] = params[:feed_city] if @profile_user[:feed_city_has_code] == "no"
      flash[:highlight] = "Profile updated!" if flash[:notice].blank?
      redirect_to @kopal_route.home
    end
  end

  def friend
    re = Proc.new {
      redirect_to @kopal_route.friend
      return
    }
    re.call if params[:identity].blank?
    @identity = Kopal::Identity.new params[:identity]

    if request.get?
      #ask for confirmation.
    elsif request.post?
      #do stuff
    end

    #TODO: It all shall be in request.post?
    @friend = @profile_user.account.all_friends.find_or_initialize_by_friend_kopal_identity @identity.to_s
    
    case params[:action2]
    when 'start'
      case @friend.friendship_state
      when 'friend'
        flash[:highlight] = "#{@friend.friend_kopal_identity.simplified} is already your friend."
        re.call
      when 'pending'
        session[:kopal][:kc_authorisation_code] = random_hexadecimal
        redirect_to @kopal_route.connect(:action => 'n_approve_pending_friendship_requests',
          :ki => @identity.to_s,
          :kc_authorisation_code => session[:kopal][:kc_authorisation_code]
        )
        return
      when 'waiting'
        flash[:highlight] = "Waiting for approval from #{@friend.friend_kopal_identity.simplified}"
        re.call
      else
        #Request goes from here, means that it is guaranteed that user is aythenticated.
        session[:kopal][:kc_authorisation_code] = random_hexadecimal
        redirect_to @kopal_route.connect(:action => 'n_initiate_friendship',
          :ki => @identity.to_s,
          :kc_authorisation_code => session[:kopal][:kc_authorisation_code]
        )
        return
      end
    when 'delete'
      @friend.destroy
      Kopal::Antenna.fetch(@friend.friend_kopal_identity.friendship_update_url(
        :'kopal.identity' => @profile_user.kopal_identity,
        :'kopal.friendship-state' => 'rejected',
        :'kopal.friendship-key' => @friend.friendship_key))
      flash[:highlight] = "Deleted friend #{@friend.friend_kopal_identity.simplified}"
      re.call
    end
    re.call
  end

  def change_password
    if request.post?
      flash.now[:notice] = "Password is blank." and return if params[:password].blank?
      flash.now[:notice] = "Passwords do not match." and return unless
        params[:password] == params[:password_confirmation]
      Kopal::KopalPreference.save_password @profile_user.account.id, params[:password]
      flash[:highlight] = "Password changed!"
      redirect_to @kopal_route.root
    end
  end

private

  #Advanced preferences.
  def preference_4hackers
    
  end
end
