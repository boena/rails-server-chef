packages = %w(
  nginx
)

packages.each { |name| package name }

###############
# NGINX
###############

template "/etc/nginx/nginx.conf" do
  owner "root"
  group "root"
  mode "0644"
  source "nginx.conf.erb"
end

# Open ports
bash "allowing nginx traffic through firewall" do
  user "root"
  code "ufw allow 'Nginx Full'"
end

service 'nginx' do
  provider Chef::Provider::Service::Systemd
  supports :restart => true
  action :restart
end


###############
# Setup Ruby w/ rbenv
###############

global_version = node[:rbenv][:global] || '2.6.0'

rbenv_system_install global_version

# Download and install versions
versions = node[:rbenv][:versions] || ['2.6.0']

versions.each do |version|
  rbenv_ruby version
end

# Set as global
rbenv_global global_version

# Setup gems
gems = node[:rbenv][:gems] || ['bundler']

versions.each do |version|
  gems.each do |gem|
    rbenv_gem gem do
      rbenv_version version
    end
  end
end

rbenv_rehash global_version


###############
# Setup Node and Yarn
###############

bash 'node' do
  user 'root'
  code <<-EOC
    curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
    apt-get update
    apt-get install -y nodejs
  EOC
end

bash 'yarn' do
  user 'root'
  code <<-EOC
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
    apt-get update
    apt-get install yarn
  EOC
end
