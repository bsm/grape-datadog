$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rack/test'

RSpec.configure do |config|
  config.include Rack::Test::Methods
end

require 'grape'
require 'grape-datadog'

class MockStatsd < Statsd
  def timing(stat, ms, opts={}); super(stat, 333, opts); end
  def flush_buffer; end
  alias :send_stat :send_to_buffer
end

$statsd = MockStatsd.new(nil, nil, {}, 10000)
