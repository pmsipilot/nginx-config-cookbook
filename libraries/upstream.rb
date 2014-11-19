module PMSIpilot
  module NginxConfig
    module Upstream
      def self.valid?(upstream)
        (upstream.key?('ip') and not upstream['ip'].empty?) or
        (upstream.key?(:ip) and not upstream[:ip].empty?)
      end

      def self.raise_if_invalid!(upstream)
        raise Chef::Exceptions::ConfigurationError, 'Invalid upstream configuration' unless valid?(upstream)

        upstream
      end

      def self.normalize!(upstream)
        normalized = raise_if_invalid!(upstream).dup

        normalized['port'] ||= 80

        normalized
      end
    end
  end
end
