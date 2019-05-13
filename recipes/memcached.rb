apt_update

packages = %w(
  memcached
  libmemcached-tools
)

packages.each { |name| package name }
