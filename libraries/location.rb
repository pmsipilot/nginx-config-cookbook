module PMSIpilot
  module NginxConfig
    module Location
      def self.valid?(location)
        (
          (location.key?('path') and not location['path'].empty?) and
          (location.key?('upstream') and not location['upstream'].empty?)
        ) or (
          (location.key?(:path) and not location[:path].empty?) and
          (location.key?(:upstream) and not location[:upstream].empty?)
        )
      end

      def self.raise_if_invalid!(location)
        raise Chef::Exceptions::ConfigurationError, 'Invalid location configuration' unless valid?(location)

        location
      end

      def self.normalize!(location)
        raise_if_invalid!(location).dup
      end
    end
  end
end
