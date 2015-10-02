require 'grape/datadog/version'
require 'grape'
require 'statsd'
require 'socket'
require 'active_support/notifications'

module Grape
  class Datadog
    include Singleton

    # Configure and install datadog instrumentation. Example:
    #
    #   Grape::Datadog.install! do |c|
    #     c.hostname = "my-host"
    #   end
    #
    # Settings:
    # * <tt>hostname</tt>    - the hostname used for instrumentation, defaults to system hostname, respects +INSTRUMENTATION_HOSTNAME+ env variable
    # * <tt>metric_name</tt> - the metric name (prefix) to use, defaults to "grape.request"
    # * <tt>tags</tt>        - array of custom tags, these can be plain strings or lambda blocks accepting a rack env instance
    # * <tt>statsd_host</tt> - the statsD host, defaults to "localhost", respects +STATSD_HOST+ env variable
    # * <tt>statsd_port</tt> - the statsD port, defaults to 8125, respects +STATSD_PORT+ env variable
    # * <tt>statsd</tt>      - custom statsd instance
    def self.install!(&block)
      block.call instance if block
      instance.send(:subscribe!)
    end

    attr_accessor :hostname, :metric_name, :statsd_host, :statsd_port, :tags
    attr_writer   :statsd

    def initialize
      @hostname     = ENV['INSTRUMENTATION_HOSTNAME'] || Socket.gethostname
      @metric_name  = "grape.request"
      @statsd_host  = ENV['STATSD_HOST'] || "localhost"
      @statsd_port  = (ENV['STATSD_PORT'] || 8125).to_i
      @tags         = []
    end

    def statsd
      @statsd ||= ::Statsd.new(statsd_host, statsd_port)
    end

    private

      def subscribe!
        if frozen?
          warn "#{self.class.name} was already initialized!"
          return
        end

        unless tags.any? {|t| t =~ /^host\:/ }
          tags.push("host:#{hostname}")
        end

        ActiveSupport::Notifications.subscribe 'endpoint_run.grape' do |_, start, finish, _, payload|
          record payload[:endpoint], ((finish-start)*1000).round
        end

        freeze
      end

      def record(endpoint, ms)
        route   = endpoint.route
        version = route.route_version
        method  = route.route_method

        path = route.route_path
        path.sub!("(.:format)", "")
        path.sub!(":version/", "") if version
        path.gsub!(/\(?:(\w+)\)?/) {|m| "_#{m[1..-1]}_" }

        tags = self.tags.map do |tag|
          case tag when String then tag when Proc then tag.call(endpoint) end
        end
        tags.push "method:#{method}"
        tags.push "path:#{path}"
        tags.push "version:#{version}" if version
        tags.push "status:#{endpoint.status}"
        tags.compact!

        statsd.increment metric_name, :tags => tags
        statsd.timing "#{metric_name}.time", ms, :tags => tags
      end

  end
end

# %w|version middleware|.each do |name|
#   require "grape/datadog/#{name}"
# end
