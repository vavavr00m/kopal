class Kopal::ConnectController < Kopal::ApplicationController
  layout 'kopal_connect.xml.builder'
  before_filter :connect_initialise

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


  #TODO: Document the fact that to Kopal Connect to work a server must be
  #able to handle two simultaneous requests or design it in such a way that
  #there never are two simultaneous requests.
  #
  #* Check if request is a duplicate request.
  #* Send a 'friendship-state' request
  #* Check is friendship state is 'waiting'
  #* Decrypt and save the friendship key recieved from 'friendship-state' request.
  #* Perform a 'discovery' request on requester and save the publick key.
  #* Get the 'kopal-feed' of the requester and save it.
  #* Publish the friendship state.
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
        :error_message => "Invalid Kopal Feed at #{@kopal_feed_response.response_uri}. " +
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
      kc_render_or_redirect :mode => 'error', :error_id => '0x1205'
      return
    end
    unless @friend.friendship_key == params[:'kopal.friendship-key']
      kc_render_or_redirect :mode => 'error', :error_id => '0x1204'
      return
    end
    
    case params[:"kopal.friendship-state"]
    when 'friend'
      @friend.friendship_state = 'friend'
      @friend.save!
    when 'rejected'
      @friend.destroy
    else
      #Invalid friendship state.
      kc_render_or_redirect :mode => 'error', :error_id => '0x1202'
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

private

  def connect_initialise
  end

  #Checks parameters if they are valid.
  #Pass a Hash of parameter name as key and required value as value. Value can be a
  #[String] - Parameter must have this exact value.
  #[Regular Expression] - Paramter must match it.
  #[Primitive value <tt>true</tt>] - Parameter must be present.
  #[Proc object with one argument] - Proc must return true and not raise any
  #exception for passed parameter value.
  #
  #OPTIMIZE: Instead of throwing exception, show an Error message in XML template.
  #TODO: Suppress exceptions of Proc.
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
        :error_message => message
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
      if hash[:error_message].empty?
        hash[:error_message] = message
      elsif hash[:error_message].is_a? Hash
        hash[:error_message] = message % hash[:error_message]
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
          :error_message => "Invalid kopal.return_to URL."
        return
      end
    end
    kc_render hash
  end

  #Indirect communication
  def kc_redirect hash
    logger.debug("In function - kc_redirect")

    return_to = Kopal::Url.new params[:'kopal.return_to']
    hash.each { |k,v|
      return_to.query_hash["kopal.#{k}"] = v
    }
    return_to.build_query
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
      kc_render_or_redirect :mode => 'error', :error_message => e.message
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
        :error_message => "#{@friend.friend_kopal_identity} did not initiate friendship."
      return
    end
    unless friendship_state == 'waiting'
      if Kopal::ProfileFriend::ALL_FRIENDSHIP_STATES.map{|x| x.to_s}.include? friendship_state
        kc_render_or_redirect :mode => 'error', :error_id => 0x1202,
          :error_message => {:state => friendship_state} #Invalid friendship state.
        return
      else #extreme?
        kc_render_or_redirect :mode => 'error', :error_id => 0x1203,
        :error_message => {:state => friendship_state} #Unknown friendship state.
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
        :error_message => "Can not decrypt friendship-key. #{e.message}."
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
        :error_message => e.message
      return
    end
    return response2
  end

  def kc_verify_kc_discovery response2
    logger.debug("Checking if response if valid Kopal Connect Discovery?")
    unless response2.kopal_connect_discovery?
      kc_render_or_redirect :mode => 'error', :error_id => '0x1100',
        :error_message => "#{response2.response_uri} is not a valid Kopal Connect Discovery."
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
        :error_message => e.message
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
      kc_render_or_redirect :mode => 'error', :error_message => 'Invalid Kopal Connect'
      return
    end
  end

  def kc_verify_k_feed response2
    logger.debug("Checking if response if valid Kopal Feed.")
    unless response2.kopal_feed?
      kc_render_or_redirect :mode => 'error', :error_id => '0x2000',
        :error_message => "#{response2.response_uri} is not a valid Kopal Feed."
      return
    end
  end
end
