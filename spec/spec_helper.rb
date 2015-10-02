ENV['RACK_ENV'] ||= 'test'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rack/test'
require 'grape-datadog'

RSpec.configure do |config|
  config.include Rack::Test::Methods
end

class MockStatsd < Statsd
  def timing(stat, ms, opts={}); super(stat, 333, opts); end
  def flush_buffer; end
  alias :send_stat :send_to_buffer
end

class VersionedTestAPI < Grape::API
  version 'v1'
  prefix  'api'

  get('versioned') { "OK" }
end

class TestAPI < Grape::API
  get 'echo/:key1/:key2' do
    "#{params['key1']} #{params['key2']}"
  end

  namespace :sub do
    mount VersionedTestAPI

    namespace :secure do
      get("/resource") { error!("forbidden", 403) }
    end
  end
end

Grape::Datadog.install! do |c|
  c.hostname = "test.host"
  c.statsd   = MockStatsd.new(nil, nil, {}, 10000)
  c.tags     = ["custom:tag", lambda{|e| "format:#{e.env['api.format']}" }]
end
