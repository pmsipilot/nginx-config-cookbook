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


  template 'configure_server' do
    source 'nginx.conf.erb'
    path "/etc/nginx/sites-available/#{server_name}.conf"
    variables server: server, server_name: server_name

    notifies :create, 'link[enable_server]', :immediately
    notifies :restart, 'service[nginx]', :delayed
  end

  link 'enable_server' do
    target_file '/etc/nginx/sites-enabled/proxy.conf'
    to '/etc/nginx/sites-available/proxy.conf'
    action :nothing

    notifies :restart, 'service[nginx]', :delayed
  end
end
