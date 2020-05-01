#
# Cookbook:: gpas-worker
# Recipe:: nodejs
#
# Copyright:: 2020, NCI-GDC, Apache v2.0.

ark 'node' do
  url node['nodejs']['url']
  version node['nodejs']['version']
  checksum node['nodejs']['checksum']
  append_env_path true
end
