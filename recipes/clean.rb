raise Chef::Exceptions::ConfigurationError, 'No configuration for cookbook' if node['nginx']['servers'].empty?

service 'nginx'

node['nginx']['servers'].each do |server_name, server|
  server = PMSIpilot::NginxConfig::Server.normalize!(server)

  file "delete_server_#{server_name}" do
    path "#{node['nginx']['sites_available']}/#{server_name}.conf"
    action :delete

    only_if { PMSIpilot::NginxConfig::Server.should_delete?(server, node) }
    notifies :restart, 'service[nginx]', :delayed
  end

  link "unlink_server_#{server_name}" do
    target_file "#{node['nginx']['sites_enabled']}/#{server_name}.conf"
    to "#{node['nginx']['sites_available']}/#{server_name}.conf"
    action :delete

    only_if { PMSIpilot::NginxConfig::Server.should_unlink?(server, node) }
    notifies :restart, 'service[nginx]', :delayed
  end
end
