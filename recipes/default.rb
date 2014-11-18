raise Chef::Exceptions::ConfigurationError, 'No configuration for cookbook' if node['nginx']['servers'].empty?

service 'nginx'

node['nginx']['servers'].each do |server_name, server|
  if (not server.key?('upstreams') or server['upstreams'].empty?) and
     (not server.key?('locations') or server['locations'].empty?) and
     (not server.key?('root') or server['root'].empty?)
    raise Chef::Exceptions::ConfigurationError, 'Invalid server configuration'
  end

  if server.key?('locations') and not server['locations'].empty?
    server['locations'].each do |location|
      has_path = (location.key?('path') and not location['path'].empty?)
      has_upstream = (location.key?('upstream') and not location['upstream'].empty?)

      raise Chef::Exceptions::ConfigurationError, 'Invalid location configuration' unless has_path and has_upstream
    end
  end

  template "create_server_#{server_name}" do
    source 'nginx.conf.erb'
    path "#{node['nginx']['sites_available']}/#{server_name}.conf"
    variables server: server, server_name: server_name

    not_if { server['enable'] === false }
    notifies :create, "link[link_server_#{server_name}]", :immediately
    notifies :restart, 'service[nginx]', :delayed
  end

  link "link_server_#{server_name}" do
    target_file "#{node['nginx']['sites_enabled']}/#{server_name}.conf"
    to "#{node['nginx']['sites_available']}/#{server_name}.conf"
    action :nothing

    not_if { node['nginx']['sites_available'] === node['nginx']['sites_enabled'] }
    notifies :restart, 'service[nginx]', :delayed
  end

  template "delete_server_#{server_name}" do
    action :delete

    only_if {
      server['enable'] === false and
      node['nginx']['sites_available'] === node['nginx']['sites_enabled']
    }
    notifies :restart, 'service[nginx]', :delayed
  end

  link "unlink_server_#{server_name}" do
    target_file "#{node['nginx']['sites_enabled']}/#{server_name}.conf"
    to "#{node['nginx']['sites_available']}/#{server_name}.conf"
    action :delete

    only_if { server['enable'] === false }
    notifies :restart, 'service[nginx]', :delayed
  end
end
