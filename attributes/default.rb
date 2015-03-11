default['nginx']['servers'] = {}
default['nginx']['dir'] = '/etc/nginx' unless node['nginx']['dir']
default['nginx']['sites_available'] = "#{node['nginx']['dir']}/conf.d"
default['nginx']['sites_enabled'] = node['nginx']['sites_available']
