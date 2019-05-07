# Setup gems
gems = node[:rbenv][:gems] || ['bundler']

gems.each do |gem|
  rbenv_gem gem
end
