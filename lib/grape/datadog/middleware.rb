require 'grape'
require 'statsd'
require 'socket'

module Grape
  module Datadog

    class Middleware < ::Grape::Middleware::Base

      attr_reader :statsd

      # Create a new +Datadog+ middleware instance.
      #
      # ==== Options
      # * <tt>:hostname</tt> - the hostname used for instrumentation, defaults to system hostname, respects +INSTRUMENTATION_HOSTNAME+ env variable
      # * <tt>:metric_name</tt> - the metric name (prefix) to use, defaults to "grape.request"
      # * <tt>:tags</tt> - array of custom tags, these can be plain strings or lambda blocks accepting a rack env instance
      # * <tt>:statsd_host</tt> - the statsD host, defaults to "localhost", respects +STATSD_HOST+ env variable
      # * <tt>:statsd_port</tt> - the statsD port, defaults to 8125, respects +STATSD_PORT+ env variable
      # * <tt>:use_global</tt> - if set, tries to find global `$statsd` instance, otherwise connects to +statsd_host+:+statsd_port. Default: true
      def initialize(app, opts = {})
        hostname    = opts[:hostname] || ENV['INSTRUMENTATION_HOSTNAME'] || Socket.gethostname
        statsd_host = opts[:statsd_host] || ENV['STATSD_HOST'] || "localhost"
        statsd_port = (opts[:statsd_port] || ENV['STATSD_PORT'] || 8125).to_i

        @app    = app
        @metric = opts[:metric_name] || "grape.request"
        @statsd = opts[:use_global] == false || !defined?($statsd) ? ::Statsd.new(statsd_host, statsd_port) : $statsd
        @tags   = opts[:tags] || []
        @tags.push "host:#{hostname}"
      end

      def call(env)
        tags = prepare_tags(env)
        statsd.time "#{@metric}.time", :tags => tags do
          resp = @app.call(env)
          tags.push "status:#{resp.status}"
          statsd.increment @metric, :tags => tags
          resp
        end
      end

      private

      def prepare_tags(env)
        path = env['api.endpoint'].routes.first.route_path[1..-1].gsub("/", ".").sub(/\(\.:format\)\z/, "").gsub(/\.:(\w+)/, '.{\1}')
        @tags.map do |tag|
          case tag
          when String
            tag
          when Proc
            tag.call(env)
          end
        end.compact + ["method:#{env[Rack::REQUEST_METHOD]}", "path:#{path}"]
      end

    end

  end
end

