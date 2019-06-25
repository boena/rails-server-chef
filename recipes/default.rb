packages = %w(
  nginx
  logrotate
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
gems = node[:rbenv][:gems] || ['bundler', 'puma']

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

if !File.exist?('/usr/bin/node') and !File.exist?('/usr/local/bin/node')
  bash 'node' do
    user 'root'
    code <<-EOC
      curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
      apt-get update
      apt-get install -y nodejs
    EOC
  end
else
  p 'NodeJS already installed, skipping...'
end

if !File.exist?('/usr/bin/yarn') and !File.exist?('/usr/local/bin/yarn')
  bash 'yarn' do
    user 'root'
    code <<-EOC
      curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
      echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
      apt-get update
      apt-get install yarn
    EOC
  end
else
  p 'Yarn already installed, skipping...'
end


###############
# Setup Site and Log rotation
###############

if node[:site] and node[:site][:domain]
  bash 'setting up file system for site' do
    user 'root'
    code <<-EOC
      mkdir -p /var/www/#{node[:site][:domain]}/shared/config
      mkdir -p /var/www/#{node[:site][:domain]}/shared/pids
      mkdir -p /var/www/#{node[:site][:domain]}/shared/sockets
      mkdir -p /var/www/#{node[:site][:domain]}/shared/public
      chown -R www-data:www-data /var/www/#{node[:site][:domain]}
      chgrp -R www-data /var/www/#{node[:site][:domain]}
    EOC
  end

  app_name = node[:site][:domain].gsub('.', '-')

  if File.exist?('/etc/nginx/sites-enabled/default')
    bash 'Disabling default Nginx site' do
      user 'root'
      code <<-EOC
        rm /etc/nginx/sites-enabled/default
      EOC
    end
  end

  template "/etc/nginx/sites-available/#{app_name}" do
    owner 'deploy'
    group 'deploy'
    mode '0640'
    source 'nginx-site-config.conf.erb'
    variables(site_shared_path: "/var/www/#{node[:site][:domain]}/shared", app_name: app_name, domain: node[:site][:domain])
  end

  if !File.exist?("/etc/nginx/sites-enabled/#{app_name}")
    bash 'Enabling Nginx site' do
      user 'root'
      code <<-EOC
        ln -s /etc/nginx/sites-available/#{app_name} /etc/nginx/sites-enabled/#{app_name}
      EOC
    end
  end

  template "/etc/logrotate.d/#{app_name}" do
    owner "root"
    group "syslog"
    mode "0644"
    source "logrotate.conf.erb"
    variables(site_shared_path: "/var/www/#{node[:site][:domain]}/shared")
  end
end
