service 'nginx' do
  supports [:restart]
  action :nothing
end


template '/etc/nginx/sites-available/proxy.conf' do
  source 'nginx.conf.erb'
  notifies :restart, 'service[nginx]', :delayed
end
