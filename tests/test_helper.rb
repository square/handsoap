require "test/unit"
require "rubygems"

require "bundler"
Bundler.setup
Bundler.require(:test)

$LOAD_PATH << "#{File.dirname(__FILE__)}/../lib/"
require 'lib/handsoap'

Handsoap.http_driver = :net_http
FakeWeb.allow_net_connect = %r{^http://127\.0\.0\.1:\d+/}
