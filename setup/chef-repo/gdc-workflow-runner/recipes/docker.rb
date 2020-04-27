  
#
# Cookbook:: ec2-slurm-worker
# Recipe:: docker
#
# Copyright:: 2020, NCI-GDC, Apache v2.0.

case node['platform']
when 'ubuntu', 'debian'
  package 'docker.io'
when 'redhat', 'centos', 'amazon'
  package 'docker'
end

service 'docker' do
  action [ :enable, :start ]
end
