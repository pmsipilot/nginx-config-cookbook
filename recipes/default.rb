raise Chef::Exceptions::ConfigurationError, 'No configuration for cookbook' if node['nginx']['servers'].empty?

service 'nginx'

node['nginx']['servers'].each do |server_name, server|
  server = PMSIpilot::NginxConfig::Server.normalize!(server)

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

    not_if do
      node['nginx']['sites_available'] === node['nginx']['sites_enabled']
    end
    notifies :restart, 'service[nginx]', :delayed
  end

  file "delete_server_#{server_name}" do
    action :delete
    path "#{node['nginx']['sites_available']}/#{server_name}.conf"

    only_if do
      server['enable'] === false and
      node['nginx']['sites_available'] === node['nginx']['sites_enabled']
    end
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
