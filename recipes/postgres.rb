###############
# Setup Postgres
###############

if !node[:postgres] or !node[:postgres][:password]
  raise ArgumentError.new('You need to provide a password for Postgres.')
end

if !node[:postgres] or !node[:postgres][:users] or !node[:postgres][:users].any?
  raise ArgumentError.new('You need to provide at least one local user.')
end

apt_update

packages = %w(
  postgresql-contrib
  libpq-dev
)

packages.each { |name| package name }

postgresql_server_install 'PostgreSQL Server install' do
  action :install
end

postgresql_server_install 'Setup PostgreSQL server' do
  password node[:postgres][:password]
  action :create
end

node[:postgres][:users].each do |user|
  postgresql_user user[:username] do
    encrypted_password user[:encrypted_password]
    createdb user[:create_db] || true
    createrole user[:create_role] || false
    superuser user[:superuser] || false
  end
end
