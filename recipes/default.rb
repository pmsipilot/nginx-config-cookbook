service 'nginx' do
  supports [:restart]
  action :nothing
end

template 'configure_server' do
  source 'nginx.conf.erb'
  path '/etc/nginx/sites-available/proxy.conf'

  notifies :create, 'link[enable_server]', :immediately
  notifies :restart, 'service[nginx]', :delayed
end

link 'enable_server' do
  target_file '/etc/nginx/sites-enabled/proxy.conf'
  to '/etc/nginx/sites-available/proxy.conf'
  action :nothing

  notifies :restart, 'service[nginx]', :delayed
end
