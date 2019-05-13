apt_update

package 'redis-server'

template "/etc/redis/redis.conf" do
  owner "redis"
  group "redis"
  mode "0640"
  source "redis.conf.txt"
end

if node[:redis] and node[:redis][:password]
  bash 'set redis password' do
    user 'root'
    code <<-EOC
      "sed -i 's/^# requirepass foobared/requirepass #{node[:redis][:password]}/g' /etc/redis/redis.conf"
    EOC
  end
end

service 'redis' do
  provider Chef::Provider::Service::Systemd
  supports :restart => true
  action :restart
end
