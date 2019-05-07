# Download and install versions
versions = node[:rbenv][:versions] || ['2.6.0']

versions.each do |version|
  rbenv_system_install version
end
