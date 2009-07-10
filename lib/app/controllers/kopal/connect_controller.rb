class Kopal::ConnectController < Kopal::ApplicationController
  layout 'kopal_connect.xml.builder'
  before_filter :connect_initialise

  def index
    redirect_to Kopal.route.root
  end

  def discovery
    
  end

  def friendship_request
    required_params(
      :'kopal.identity' => Proc.new {|x| normalise_url(x); true}
    )
    friend_identity = normalise_url(params[:'kopal.identity'])
    render_kopal_error 0x1201 and return if #Duplicate friendship request
      UserFriend.find_by_kopal_identity(friend_identity)
    @friend = UserFriend.new
    @friend.kopal_identity = friend_identity
    begin
      f_s = Kopal.fetch(@friend.kopal_identity.friendship_state_url)
    rescue Kopal::Antenna::FetchingError => e
      render_kopal_error e.message
      return
    end
    render_kopal_error "Invalid Kopal Connect" and return unless f_s.kopal_connect?
    friendship_state = f_s.body_xml.root.elements["FriendshipState"].
      attributes["state"]
    unless friendship_state == 'waiting'
      if UserFriend::ALL_FRIENDSHIP_STATES.map{|x| x.to_s}.include? friendship_state
        render_kopal_error 0x1202 #Invalid friendship state.
      else #extreme?
        render_kopal_error 0x1203 #Unknown friendship state.
      end
      return
    end
    begin
      @friend.friendship_key = @profile_user.private_key!.private_decrypt(
        Base64.decode64 f_s.body_xml.root.elements["FriendshipKey"].text
      )
    rescue OpenSSL::PKey::RSAError
      render_kopal_error "Invalid encrypted friendship key."
      return
    end
    begin
      f_d = Kopal.fetch(@friend.kopal_identity.discovery_url)
    rescue Kopal::Antenna::FetchingError => e
      render_kopal_error e.message
      return
    end
    render_kopal_error f_d.response_uri + " is not a valid Kopal Connect discovery." and
      return unless f_d.kopal_connect_discovery?
    @friend.public_key = f_d.kopal_connect_discovery.elements["PublicKey"].text
    begin
      f_f = Kopal.fetch(@friend.kopal_identity.feed_url)
    rescue Kopal::Antenna::FetchingError => e
      render_kopal_error e
      return
    end
    render_kopal_Error "Invalid Kopal Feed." and return unless f_f.kopal_feed?
    begin
      @friend.kopal_feed = Kopal::Feed.new f_f.body_xml
      @friend.friendship_state = 'pending'
      @friend.save!
    rescue Kopal::KopalFeedInvalid, ActiveRecord::RecordInvalid => e
      render_kopal_error "Invalid Kopal Feed at #{fd.response_uri}. " +
        "Message recieved - \n" + e.message
      return
    end
    friendship_state
  end

  def friendship_update
    required_params( :"kopal.friendship-state" => true,
      :"kopal.friendship-key" => true,
      :"kopal.identity" => Proc.new {|x| normalise_url(x); true}
    )
    @friend = UserFriend.find_by_kopal_identity normalise_url params[:"kopal.identity"]
    render_kopal_error 0x1205 and return unless @friend
    render_kopal_error 0x1204 and return unless
      @friend.friendship_key == params[:"kopal.friendship-key"]
    case params[:"kopal.friendship-state"]
    when 'friend'
      @friend.friendship_state = 'friend'
      @friend.save!
    when 'rejected'
      @friend.destroy
    else
      render_kopal_error 0x1202 #Invalid friendship key.
      return
    end
    friendship_state
  end

  def friendship_state
    required_params(
      :"kopal.identity" => Proc.new {|x| normalise_url(x); true}
    )
    @friend ||= Kopal::UserFriend.find_or_initialise_readonly normalise_url params[:"kopal.identity"]
    render :friendship_state #necessary, since called by other methods.
  end

private

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
    a.each { |k,v|
      case v
      when String:
        raise ArgumentError, "Value of GET parameter #{k} must be #{v}." unless
          v == params[k]
      when Regexp:
        raise ArgumentError, "GET parameter #{k} has invalid syntax." unless
          params[k] =~ v
      when true:
        raise ArgumentError, "GET parameter #{k} must be present." if
          params[k].blank?
      when Proc:
        raise ArgumentError, "GET parameter #{k} has invalid syntax." unless
          begin
            true == v.call(params[k])
          rescue
            false
          end
      end
    }
  end

  #TODO: Make header content-type to "application/x-kopal-discovery+xml"
  def connect_initialise
  end
end
