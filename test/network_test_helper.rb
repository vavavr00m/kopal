require File.dirname(__FILE__) + '/test_helper'
#Tests that require network resources to run. For example: OpenID authentication, Kopal Connect etc.
#Run with `rake test:network`
#Example <tt> rake test:network server=thin port=3010</tt>
#Default server => thin, port => 3010
#(WEBrick may not handle two connection simultaneously (right?), which is required in this testing).
#if it does, make default server to be default of application. (WEBrick in most cases).
#
#== Setup
#*Note* - If overriding +setup+ and +teardown+, please call </tt>super()</tt>.
#
#In order to run these tests, following four domains must be pointing to
#loopback address i.e., <tt>127.0.0.1</tt> ot <tt>::1</tt>.
#
# 0. a.kopal.test
# 0. b.kopal.test
# 0. c.kopal.test
# 0. d.kopal.test
class Kopal::NetworkTestHelper < ActionController::IntegrationTest

  attr_reader :server_port, :server_name, :server
  
  def setup
    @server_name = ENV['server'] || 'thin'
    @server_port = ENV['port'] || 3010
    return #For now start servers manually.
    #If try with system(), it blocks.
    #If try with <tt>-d</tt> option, can't get correct pid.
    @server = IO.popen("#{RAILS_ROOT}/script/server #{@server_name} -p #{@server_port} -e test")
  end
  
  def teardown
    return
    #@server.close doesn't work
    if @server_name.downcase == 'webrick'
      system "kill -9 #{@server.pid}"
    else
      system "kill #{@server.pid}"
    end
  end
end

