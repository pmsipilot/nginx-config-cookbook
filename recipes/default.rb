raise Chef::Exceptions::ConfigurationError, 'No configuration for cookbook' if node['nginx']['servers'].empty?

service 'nginx' do
  supports [:restart]
  action :nothing
end

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

  template "configure_server_#{server_name}" do
    source 'nginx.conf.erb'
    path "/etc/nginx/sites-available/#{server_name}.conf"
    variables server: server, server_name: server_name

    notifies :create, "link[enable_server_#{server_name}]", :immediately
    notifies :restart, 'service[nginx]', :delayed
  end

  link "enable_server_#{server_name}" do
    target_file "/etc/nginx/sites-enabled/#{server_name}.conf"
    to "/etc/nginx/sites-available/#{server_name}.conf"
    action :nothing

    notifies :restart, 'service[nginx]', :delayed
  end
end
