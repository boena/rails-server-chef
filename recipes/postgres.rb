###############
# Setup Postgres
###############

if !node[:postgres] or !node[:postgres][:password]
  raise ArgumentError.new('You need to provide a password for Postgres.')
end

if !node[:postgres] or !node[:postgres][:database_name]
  raise ArgumentError.new('You need to provide a database name for Postgres.')
end

if !node[:postgres] or !node[:postgres][:users] or !node[:postgres][:users].any?
  raise ArgumentError.new('You need to provide at least one local user.')
end

postgresql_server_install 'PostgreSQL Server install' do
  action :install
end

postgresql_server_install 'Setup PostgreSQL server' do
  password node[:postgres][:password]
  action :create
end

node[:postgres][:users].each do |user|
  postgresql_user user[:username] do
    password user[:password]
    createdb user[:create_db] || true
    createrole user[:create_role] || false
    superuser user[:superuser] || false
  end
end

postgresql_database node[:postgres][:database_name] do
  locale 'sv_SE.utf8'
  owner node[:postgres][:users].first[:username]
  action :create
end

service 'postgresql' do
  provider Chef::Provider::Service::Systemd
  supports :restart => true
  action :restart
end
