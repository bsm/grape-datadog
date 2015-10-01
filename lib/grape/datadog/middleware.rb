require 'grape'
require 'statsd'
require 'socket'

module Grape
  module Datadog

    class Middleware < ::Grape::Middleware::Base

      # Create a new +Datadog+ middleware instance.
      #
      # ==== Options
      # * <tt>:hostname</tt> - the hostname used for instrumentation, defaults to system hostname, respects +INSTRUMENTATION_HOSTNAME+ env variable
      # * <tt>:metric_name</tt> - the metric name (prefix) to use, defaults to "grape.request"
      # * <tt>:tags</tt> - array of custom tags, these can be plain strings or lambda blocks accepting a rack env instance
      # * <tt>:statsd_host</tt> - the statsD host, defaults to "localhost", respects +STATSD_HOST+ env variable
      # * <tt>:statsd_port</tt> - the statsD port, defaults to 8125, respects +STATSD_PORT+ env variable
      # * <tt>:prefer_global</tt> - if set, tries to find global `$statsd` instance, otherwise connects to +statsd_host+:+statsd_port. Default: true
      def initialize(app, opts = {})
        hostname    = opts[:hostname] || ENV['INSTRUMENTATION_HOSTNAME'] || Socket.gethostname
        statsd_host = opts[:statsd_host] || ENV['STATSD_HOST'] || "localhost"
        statsd_port = (opts[:statsd_port] || ENV['STATSD_PORT'] || 8125).to_i

        @app    = app
        @metric = opts[:metric_name] || "grape.request"
        @statsd = opts[:prefer_global] == false || !defined?($statsd) ? ::Statsd.new(statsd_host, statsd_port) : $statsd
        @tags   = opts[:tags] || []
        @tags  += ["host:#{hostname}"]
      end

      def call(env)
        tags = prepare_tags(env)
        @statsd.time "#{@metric}.time", :tags => tags do
          resp = @app.call(env)
          tags.push "status:#{resp.status}"
          @statsd.increment @metric, :tags => tags
          resp
        end
      end

      private

      def prepare_tags(env)
        endpoint = env['api.endpoint']
        path     = File.join endpoint.namespace, endpoint.options[:path].join('/').gsub(/:(\w+)/) {|m| "_#{m[1..-1]}_" }
        versions = endpoint.namespace_inheritable(:version)
        version  = versions.first if versions

        @tags.map do |tag|
          case tag when String then tag when Proc then tag.call(env) end
        end.compact + [
          "method:#{env[Rack::REQUEST_METHOD]}",
          "path:#{path}",
          (version ? "version:#{version}" : nil),
        ].compact
      end

    end

  end
end

