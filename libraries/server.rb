module PMSIpilot
  module NginxConfig
    module Server
      def self.valid?(server)
        (server.key?('upstreams') and not server['upstreams'].empty?) or
        (server.key?(:upstreams) and not server[:upstreams].empty?) or

        (server.key?('locations') and not server['locations'].empty?) or
        (server.key?(:locations) and not server[:locations].empty?) or

        (server.key?('root') and not server['root'].empty?) or
        (server.key?(:root) and not server[:root].empty?)
      end

      def self.raise_if_invalid!(server)
        raise Chef::Exceptions::ConfigurationError, 'Invalid server configuration' unless valid?(server)

        server
      end

      def self.normalize!(server)
        normalized = raise_if_invalid!(server).dup

        normalized['port'] ||= 80
        normalized['enable'] = true unless normalized.key?('enable') and not normalized['enable'].nil?
        normalized['upstreams'] = server['upstreams'].dup if server.key?('upstreams')
        normalized['upstreams'] ||= []
        normalized['locations'] = server['locations'].dup if server.key?('locations')
        normalized['locations'] ||= []

        normalized['upstreams'].dup.each do |upstream_name, upstream|
          normalized['upstreams'][upstream_name] = PMSIpilot::NginxConfig::Upstream.normalize!(upstream)
        end

        normalized['locations'].dup.each_with_index do |location, key|
            normalized['locations'][key] = PMSIpilot::NginxConfig::Location.normalize!(location)
        end

        normalized
      end

      def self.should_delete?(server, node)
        puts server['enable'] === false && node['nginx']['sites_available'] === node['nginx']['sites_enabled']
        server['enable'] === false && node['nginx']['sites_available'] === node['nginx']['sites_enabled']
      end

      def self.should_unlink?(server, node)
        server['enable'] === false && (not node['nginx']['sites_available'] === node['nginx']['sites_enabled'])
      end
    end
  end
end
