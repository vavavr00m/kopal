#Public methods prefixed with "n_" do not relate to a Kopal Connect subject.
class Kopal::ConnectController < Kopal::ApplicationController

  class InvalidAuthorisationCode < Kopal::ApplicationError; end
  
  before_filter :connect_initialise
  before_filter :verify_authorisation_code, :only => [
    :n_approve_pending_friendship_request,
    :n_accept_updated_friendship_request,
    :n_initiate_friendship,
    :n_accept_response_from_friendship_request
  ]

  SUPPORTED_NS = [ #Index 0 should always be the revision of the responses.
    'http://spec.kopal.googlecode.com/hg/connect/0.2.draft/'
  ]

  def index
    redirect_to @kopal_route.root
  end

  def discovery
    kc_render_or_redirect :mode => 'success', :identity => @profile_user.kopal_identity,
      :name => @profile_user.feed.name, :'public-key' => @profile_user.public_key.to_pem
    #:'public-key-algorithm (or spec)' => 'PKCS#1'
  end

  #@deprecated
  def signin_request
    redirect_to @kopal_route.signin :return_after_signin => params[:"kopal.returnurl"],
      :via_kopal_connect => true
  end

  #Send a friendship request.
  def request_friendship
    return unless required_params(
      :'kopal.identity' => Proc.new {|x| Kopal::Identity.normalise_identity(x); true}
    )

    logger.info "#{params[:'kopal.identity']} requested us to initiate friendship."

    friend = @profile_user.account.all_friends.find_by_friend_kopal_identity params[:'kopal.identity']
    if friend
      kc_render_or_redirect :mode => 'error', :error_id => '0x1201',
        :message => "Can not initiate friendship request." +
        " Friendship state is already #{friend.friendship_state}"
      return
    end

    redirect_to @kopal_route.organise(:action => 'friend',
      :action2 => 'start', :identity => params[:'kopal.identity'])
  end


  #Recieve and process an incoming friendship request.
  def friendship_request
    logger.debug("In function - friendship-request")
    
    return unless required_params(
      :'kopal.identity' => Proc.new {|x| normalise_kopal_identity(x); true}
    )

    logger.info "Friendship request arrived from #{params[:'kopal.identity']}."

    @friend = @profile_user.account.all_friends.build :friend_kopal_identity => params[:"kopal.identity"]

    if @profile_user.account.all_friends.find_by_friend_kopal_identity(@friend.friend_kopal_identity.to_s)
      logger.debug("Duplicate friendship request from #{@friend.friend_kopal_identity}")
      kc_render_or_redirect :mode => 'error', :error_id => "0x1201"
      return
    end

    #TODO: Try &&ing all statements. Make sure that all of them return !nil/false if success.
    #TODO: Make all of these methods return a Proc, so that they make calling method return
    #on error like <tt>re.call</tt> in OrganiseController#friend. And we don't have
    #to perform check after every call.
    #Example: <tt>fr_fetch_friendship_state().call()</tt> instead of <tt>fr_fetch_friendship_state()<tt>.

    @friendship_state_response = fr_fetch_friendship_state
    return if ror_already?
    
    kc_verify_k_connect @friendship_state_response
    return if ror_already?
    
    fr_verify_friendship_state @friendship_state_response
    return if ror_already?
    
    @friend.friendship_key = fr_decrypt_friendship_key @friendship_state_response
    return if ror_already?
    
    @discovery_response = fr_fetch_kopal_discovery
    return if ror_already?
    
    kc_verify_k_connect @discovery_response
    return if ror_already?
    
    kc_verify_kc_discovery @discovery_response 
    return if ror_already?
    
    @friend.friend_public_key = @discovery_response.response_hash['kopal.public-key']

    @kopal_feed_response = fr_fetch_kopal_feed
    return if ror_already?

    kc_verify_k_feed @kopal_feed_response
    return if ror_already?

    logger.debug("Saving record to database.")
    begin
      @friend.friend_kopal_feed = Kopal::Feed.new @kopal_feed_response.body_xml
      @friend.friendship_state = 'pending'
      @friend.save!
    rescue Kopal::Feed::FeedInvalid, ActiveRecord::RecordInvalid => e
      kc_render_or_redirect :mode => 'error', :error_id => '0x0000',
        :message => "Invalid Kopal Feed at #{@kopal_feed_response.response_uri}. " +
        "Message recieved - " + e.message
      return
    end
    logger.debug("Finished saving record to database.")
    
    friendship_state
  end

  def friendship_update
    logger.debug("In function - friendship_update")
    return unless required_params( :"kopal.friendship-state" => true,
      :"kopal.friendship-key" => true,
      :"kopal.identity" => Proc.new {|x| normalise_kopal_identity(x); true}
    )
    @friend = @profile_user.account.all_friends.
      find_by_friend_kopal_identity normalise_url params[:"kopal.identity"]
    unless @friend
      kc_render_or_redirect :mode => 'error', :error_id => '0x1205', #unknown kopal identity.
        :message => {:identity => params[:'kopal.identity']}
      return
    end
    unless @friend.friendship_key == params[:'kopal.friendship-key']
      kc_render_or_redirect :mode => 'error', :error_id => '0x1204' #invalid friendship key
      return
    end
    
    case /#{@friend.friendship_state}, #{params[:"kopal.friendship-state"]}/
    when /^.*, rejected/
      @friend.destroy
    when /^pending, .*$/
      kc_render_or_redirect :mode => 'error', :error_id => 0x1202,
        :message => 'Pending for user\'s approval.'
      return
    when /^friend, friend$/
      nil
    when /^friend, .*$/
    else
      #Invalid friendship state.
      kc_render_or_redirect :mode => 'error', :error_id => '0x1202',
        :message => {:state => params[:"kopal.friendship-state"]}
      return
    end
    
    friendship_state
  end

  def friendship_state
    logger.debug('In function - friendship_state')
    return unless required_params(
      :"kopal.identity" => Proc.new {|x| normalise_kopal_identity(x); true}
    )
    logger.debug("RECORDS OF PROFILE FRIEND - #{Kopal::ProfileFriend.find(:all)}")
    @friend ||= Kopal::ProfileFriend.find_or_initialise_readonly @profile_user.account.id,
      normalise_kopal_identity(params[:"kopal.identity"])
    return_hash = {:mode => 'success', :'friendship-state' => @friend.friendship_state,
      'identity' => @friend.friend_kopal_identity.to_s }
    if @friend.friendship_state == 'waiting'
      logger.debug("Encrypting string #{@friend.friendship_key} with #{@friend.friend_public_key.to_pem}")
      encrypted = Base64.encode64 @friend.friend_public_key.public_encrypt(@friend.friendship_key)
      logger.debug("Encrypted friendship key is #{encrypted}")
      return_hash[:'friendship-key-encrypted'] = encrypted
    end
    kc_render_or_redirect return_hash
  end

  #Shall be a POST request.
  def n_approve_pending_friendship_request
    @fki = Kopal::Identity.new params[:ki]
    @friend = @profile_user.account.pending_friends.find_by_friend_kopal_identity(@fki)
    #TODO: Validations according to specs.
    @friend.friendship_state = 'friend'
    @friend.save!
    session[:kopal][:kc_authorisation_code] = random_hexadecimal
    redirect_to @friend.friend_kopal_identity.friendship_update_url(
      :'kopal.identity' => @profile_user.kopal_identity,
      :'kopal.state' => 'friend',
      :'kopal.friendship-key' => @friend.friendship_key,
      :'kopal.return_to' => @kopal_route.connect(
        :action => 'n_accept_updated_friendship_request',
        :kc_authorisation_code => session[:kopal][:kc_authorisation_code],
        :fki => @friend.friend_kopal_identity.to_s
      )
    )
  end

  def n_accept_updated_friendship_request
    @friend = @profile_user.account.all_friends.find_by_friend_kopal_identity(params[:fki])
    #Assumes friendship is updated.
    flash[:highlight] = "#{@friend.friend_kopal_identity.simplified} is now your friend."
    redirect_to @kopal_route.friend
  end

  def n_initiate_friendship
    #Display message in a user friendly way. Loading layout and with buttons "Continue" etc.
    #params['kopal.return_to'] = {:action => 'n_display_message_to_user'}
    @fki = Kopal::Identity.new params[:ki]
    @friend = @profile_user.account.all_friends.build :friend_kopal_identity => @fki.to_s

    (@discovery_response = fr_fetch_kopal_discovery) &&
      (kc_verify_k_connect @discovery_response) &&
      (kc_verify_k_discovery @discovery_response)
    
    return if ror_already?

    @friend.friend_public_key = @discovery_response.response_hash['kopal.public-key']

    (@kf_response = fr_fetch_kopal_feed) &&
      (kc_verify_k_feed @kf_response)

    return if ror_already?

    @friend.friend_kopal_feed = Kopal::Feed.new @kf_response
    @friend.friendship_state = 'waiting'
    @friend.assign_key!
    @friend.save! #What if following redirect fails? Second request won't be possible
    #because state is already 'waiting'. Design Kopal Connect to be atomic, like
    #currency transactions.

    session[:kopal][:kc_authorisation_code] = random_hexadecimal
    redirect_to @friend.friend_kopal_identity.friendship_request_url(
      :'kopal.identity' => @profile_user.kopal_identity,
      :'kopal.return_to' => @kopal_route.connect(
        :action => 'n_accept_response_from_friendship_request',
        :fki => @friend.friend_kopal_identity,
        :kc_authorisation_code => session[:kopal][:kc_authorisation_code],
        :only_path => false
      )
    )
  end

  def n_accept_response_from_friendship_request #n_initiate_friendship_request_2
    @friend = @profile_user.account.waiting_friends.find_by_friend_kopal_identity(params[:fki])
    @state = params[:'kopal.friendship-state']
    unless ['pending', 'friend', 'rejected'].include? @state
      logger.debug("Invalid friendship state - #{@state}")
      flash[:notice] = "Friendship state has invalid value - #{@state}"
    else
      if @state == 'rejected'
        @friend.destory
        flash[:highlight] = "Friendship declined by #{@friend.friend_kopal_identity.simplified}"
      else
        @friend.friendship_state = if @state == 'pending' then 'waiting' else 'friend' end
        @friend.save!
        flash[:highlight] = "Friendship state of #{@friend.friend_kopal_identity.simplified} is now #{@friend.friendship_state}"
      end
    end
    redirect_to @kopal_route.friend
  end

private

  def connect_initialise
  end

  #For actions that require authentication and permission (collectively authorisation)
  #It should not be like anyone can forge a request to that action if the profile user is signed in.
  #Should be a POST/PUT request.
  #Can achieve with InvalidAuthenticityToken?
  #
  #FIXME: It is possible that an external uri makes request to another action while
  #the authorisation code is set and some other action is expected. Also store in session
  #the authorisation code as well as for which action it is with what params expected.
  #for example params[:fki] must be http://example.net/ for a perticular action with
  #a perticular authorisation code.
  def verify_authorisation_code
    if params[:kc_authorisation_code].blank?() or
        session[:kopal].delete(:kc_authorisation_code) != params[:kc_authorisation_code]
      raise InvalidAuthorisationCode
    end
  end

  #Checks parameters if they are valid.
  #Pass a Hash of parameter name as key and required value as value. Value can be a
  #[String] - Parameter must have this exact value.
  #[Regular Expression] - Paramter must match it.
  #[Primitive value <tt>true</tt>] - Parameter must be present.
  #[Proc object with one argument] - Proc must return true and not raise any
  #exception for passed parameter value.
  #
  #TODO: Suppress exceptions of Proc.
  #
  #Make it return a proc. Which renders or redirects error and returns from the calling
  #method. Like re.call() in OrganiseController#friend
  #So that we can use it like <tt>required_params.call(stuff)</tt> and don't have to write
  #<tt>return unless required_params(stuff)</tt>
  def required_params a
    message = nil
    a.each { |k,v|
      case v
      when String:
        message =  "Value of GET parameter #{k} must be #{v}." unless
          v == params[k]
      when Regexp:
        message = "GET parameter #{k} has invalid syntax." unless
          params[k] =~ v
      when true:
        message = "GET parameter #{k} must be present." if
          params[k].blank?
      when Proc:
        message = "GET parameter #{k} has invalid syntax." unless
          begin
            true == v.call(params[k])
          rescue
            false
          end
      end
    }
    if message
      kc_render_or_redirect :mode => 'error', :error_id => '0x1000',
        :message => message
      return false
    end
    true #all good.
  end

  def rendered_or_redirected_already?
    @rendered_or_redirected_already
  end

  alias ror_already? rendered_or_redirected_already?

  #+render_or_redirect+ sounds quite generic, say if Rails implements it in future.
  def kc_render_or_redirect hash
    logger.debug("In function -  kc_render_or_redirect.")
    logger.debug("Hash is #{hash.inspect}")

    @rendered_or_redirected_already = true

    hash['connect'] ||= SUPPORTED_NS[0]

    if hash[:error_id]
      message = Kopal::KOPAL_ERROR_CODE_PROTOTYPE[hash[:error_id].to_i(16)]
      if hash[:message].blank?
        hash[:message] = message
      elsif hash[:message].is_a? Hash
        hash[:message] = message % hash[:message]
      end
    end

    if params[:'kopal.return_to']
      begin
        #Must be an absolute url.
        unless params[:'kopal.return_to'] =~ /^https?:\/\//
          raise URI::InvalidURIError
        end
        URI.parse params[:'kopal.return_to']
        kc_redirect hash
        return
      rescue URI::InvalidURIError => e
        kc_render :mode => 'error', :error_id => '0x0000',
          :message => "Invalid kopal.return_to URL."
        return
      end
    end
    kc_render hash
  end

  #Indirect communication
  def kc_redirect hash
    logger.debug("In function - kc_redirect")
    
    # So, cool!
    # Second thought, should not rely on values being key (inverting).
    # Saw on web, not my original.
    # See also Kopal::HomeController#index
    # hash = hash.invert.merge(hash.invert) {|k,v| "kopal.#{v}"}.invert
    hash = hash.hmap { |k,v| ["kopal.#{k}", v]}

    return_to = Kopal::Url.new params[:'kopal.return_to']
    return_to.update_parameters hash
    #is status code right?
    redirect_to return_to.to_s, :status => 300 #Multiple choices
  end

  #Direct communication
  def kc_render hash
    logger.debug("In function - kc_render")

    #Doesn't work
    #response.status = 400 if hash[:mode] == 'error'
    response.content_type = 'text/plain'
    
    response2 = ''

    hash.each { |k,v|
      response2 << "kopal.#{k}: #{CGI.escape(v.to_s)}\n"
    }

    if hash[:mode] == 'error'
      render :text => response2, :status => 400
    else
      render :text => response2
    end
  end

  def fr_fetch_friendship_state
    url = @friend.friend_kopal_identity.friendship_state_url @profile_user.kopal_identity
    logger.debug("Fetching friendship-state from #{url}")
    begin
      response2 = Kopal::Antenna.fetch(url)
      logger.debug("Finished fetching friendship-state from #{url}.")
    rescue Kopal::Antenna::FetchingError => e
      kc_render_or_redirect :mode => 'error', :message => e.message
      return
    end
    return response2
  end

  def fr_verify_friendship_state response2
    logger.debug("In function - fr_verify_friendship_state")
    
    friendship_state = response2.response_hash['kopal.friendship-state']
    logger.debug("friendship-state is #{friendship_state}.")

    if friendship_state == 'none'
      kc_render_or_redirect :mode => 'error', :error_id => '0x1202',
        :message => "#{@friend.friend_kopal_identity} did not initiate friendship."
      return
    end
    unless friendship_state == 'waiting'
      if Kopal::ProfileFriend::ALL_FRIENDSHIP_STATES.map{|x| x.to_s}.include? friendship_state
        kc_render_or_redirect :mode => 'error', :error_id => 0x1202,
          :message => {:state => friendship_state} #Invalid friendship state.
        return
      else #extreme?
        kc_render_or_redirect :mode => 'error', :error_id => 0x1203,
        :message => {:state => friendship_state} #Unknown friendship state.
        return
      end
    end
  end

  def fr_decrypt_friendship_key response2
    logger.debug("In function - fr_decrypt_friendship_key")
    begin
      logger.debug("Transmitted friendship key is #{response2.response_hash['kopal.friendship-key-encrypted']}")
      logger.debug("Decrypting frienship key with private key! of public key #{@profile_user.private_key!.public_key}.")
       friendship_key = @profile_user.private_key!.private_decrypt(
        Base64.decode64 response2.response_hash['kopal.friendship-key-encrypted']
      )
      logger.debug("Finished decrypting friendship key.")
    rescue OpenSSL::PKey::RSAError => e
      kc_render_or_redirect :mode => 'error', :error_id => '0x1204',
        :message => "Can not decrypt friendship-key. #{e.message}."
      return
    end
    return friendship_key
  end

  def fr_fetch_kopal_discovery
    logger.debug("In function - fr_fetch_kopal_discovery")
    url = @friend.friend_kopal_identity.discovery_url
    logger.debug("Fetching Kopal Connect Discovery from #{url}")
    begin
      response2 = Kopal::Antenna.fetch(url)
    rescue Kopal::Antenna::FetchingError => e
      kc_render_or_redirect :mode => 'error', :error_id => '0x1100',
        :message => e.message
      return
    end
    return response2
  end

  def kc_verify_kc_discovery response2
    logger.debug("Checking if response if valid Kopal Connect Discovery?")
    unless response2.kopal_connect_discovery?
      kc_render_or_redirect :mode => 'error', :error_id => '0x1100',
        :message => "#{response2.response_uri} is not a valid Kopal Connect Discovery."
      return
    end
  end

  def fr_fetch_kopal_feed
    url = @friend.friend_kopal_identity.feed_url
    logger.debug("Fetching Kopal Feed from #{url}")
    begin
      response2 = Kopal::Antenna.fetch(url)
    rescue Kopal::Antenna::FetchingError => e
      kc_render_or_redirect :mode => 'error', :error_id => '0x2000',
        :message => e.message
      return
    end
    return response2
  end

  def kc_verify_k_connect response2
    logger.debug("In function - kc_verify_response")

    #Content-Type SHOULD be text/plain.
    logger.debug("Response content-type is #{response2.headers[:content_type]}")
    logger.debug("Response Kopal Connect response is #{CGI.unescape(response2.body_raw)}")

    logger.debug("Checking if Kopal Connect revision is supported.")
    if response2.kopal_connect?
      unless SUPPORTED_NS.include? response2.response_hash['kopal.connect']
        kc_render_or_redirect :mode => 'error', :error_id => '0x1010'
        return
      end
    else
      kc_render_or_redirect :mode => 'error', :message => 'Invalid Kopal Connect'
      return
    end
  end

  def kc_verify_k_feed response2
    logger.debug("Checking if response if valid Kopal Feed.")
    unless response2.kopal_feed?
      kc_render_or_redirect :mode => 'error', :error_id => '0x2000',
        :message => "#{response2.response_uri} is not a valid Kopal Feed."
      return
    end
  end
end
