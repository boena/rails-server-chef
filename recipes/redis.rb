apt_update

package 'redis-server'

template "/etc/redis/redis.conf" do
  owner "redis"
  group "redis"
  mode "0640"
  source "redis.conf.erb"
  variables(redis_password: node[:redis][:password])
end

service 'redis' do
  provider Chef::Provider::Service::Systemd
  supports :restart => true
  action :restart
end
