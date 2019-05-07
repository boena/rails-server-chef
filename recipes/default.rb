# Download and install versions
versions = node[:rbenv][:versions] || ['2.6.0']

versions.each do |version|
  rbenv_system_install version
end

# Set as global
rbenv_global node[:rbenv][:global] || '2.6.0'

# Setup gems
gems = node[:rbenv][:gems] || ['bundler']

gems.each do |gem|
  rbenv_gem gem
end
