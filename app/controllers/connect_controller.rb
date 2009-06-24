class ConnectController < ApplicationController
  layout 'connect.xml.builder'
  before_filter :connect_initialise

  def index
    redirect_to root_path
  end

  def discovery
    required_params(:"kopal.subject" => 'discovery')
  end

  def friendship_request
    required_params(:"kopal.subject" => 'friendship-request', #unnecessary?
      :'kopal.friend-identity' => Proc.new {|x| normalise_url(x); true}
    )
    friend_identity = normalise_url(params[:'kopal.friend-identity'])
    if u = UserFriend.find_by_kopal_identity(friend_identity)
      @state = u.friendship_state
    else
      f = UserFriend.new
      f.kopal_identity = friend_identity
      begin
        f_d = Kopal.fetch(f.kopal_identity.discovery_url)
      rescue Kopal::Antenna::FetchingError => e
        render_kopal_error e.message
        return
      end
      render_kopal_error f_d.response_uri + " is not a valid Kopal Connect discovery." and
        return unless f_d.kopal_connect_discovery?
      public_key = f_d.kopal_connect_discovery.elements["PublicKey"].text
      begin
        fd = Kopal.fetch(f.kopal_identity.feed_url)
      rescue Kopal::Antenna::FetchingError => e
        render_kopal_error e
        return
      end
      if fd.kopal_feed?
        begin
          feed = Kopal::Feed.new fd.body_xml
          f.kopal_feed = feed
          @friendship_key = f.friendship_key = random_hexadecimal(40)
          f.public_key = public_key
          @state = f.friendship_state = 'pending'
          f.save!
        rescue Kopal::KopalFeedInvalid, ActiveRecord::RecordInvalid => e
          render_kopal_error "Invalid Kopal Feed at #{fd.response_uri}. " + 
            "Message recieved - \n" + e.message
          return
        end
      end
    end
    render :friendship_state
  end

  def friendship_update
    d
  end

  def friendship_state
    
  end

private

  #Checks parameters if they are valid.
  #Pass a Hash of parameter name as key and required value as value. Value can be a
  #[String] - Parameter must have this exact value.
  #[Regular Expression] - Paramter must match it.
  #[Primitive value <tt>true</tt>] - Parameter must be present.
  #[Proc object with one argument] - Proc must return true for passed parameter value.
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
          true == v.call(params[k])
      end
    }
  end

private

  #TODO: Make header content-type to "application/x-kopal-discovery+xml"
  def connect_initialise
  end
end
