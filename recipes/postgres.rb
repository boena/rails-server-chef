###############
# Setup Postgres
###############

if !node[:postgres] or !node[:postgres][:password]
  raise ArgumentError.new('You need to provide a password for Postgres.')
end

postgresql_server_install 'PostgreSQL Server install' do
  action :install
end

postgresql_server_install 'Setup PostgreSQL server' do
  password node[:postgres][:password]
  action :create
end
