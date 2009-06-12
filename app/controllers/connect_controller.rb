class ConnectController < ApplicationController
  layout 'connect.xml.builder'
  before_filter :initialise

  def index
    redirect_to root_path
  end

  def discovery
    required_params(:"kopal.subject" => 'discovery')
  end

  def friendship_request
    required_params(:"kopal.subject" => 'friendship-request', #unnecessary?
      :'kopal.friend-identity' => Proc.new {|x| normalise_url(x); true} #,
      #Reply with encryption of random-number of private key for verification?
      #:"kopal.random-number" => Proc.new {|x| valid_hexadecimal?(x)}
    )
    friend_identity = normalise_url(params[:'kopal.friend-identity'])
    if @profile_user.friend? friend_identity
      @state = 'friend'
    else
      f = UserIdentity.new
      f.kopal_identity = friend_identity
      fd = Kopal.fetch(f.url_kopal_feed)
      if fd.kopal_feed?
        feed = Kopal::Feed.new fd.body_xml
        f.name = feed.name
      end
      @state = 'pending'
    end
    render :friendship_state
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
  def initialise
  end
end
