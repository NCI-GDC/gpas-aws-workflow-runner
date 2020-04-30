#
# Cookbook:: ec2-slurm-worker
# Recipe:: os_base
#
# Copyright:: 2020, NCI-GDC, Apache v2.0.

include_recipe 'apt'
include_recipe 'yum-epel'
include_recipe 'os-hardening'

build_essential 'Install build essentials'
package %w(unzip libtool awscli nvme-cli)

directory '/root/.aws'

file '/root/.aws/config' do
  content "[default]
region = #{node['ec2']['region']}"
end

case node['platform']
when 'redhat', 'centos', 'amazon'
  package 'pcre-tools'
when 'ubuntu', 'debian'
  package 'pcregrep'
end

directory '/opt/aws'

cookbook_file '/opt/aws/mountEphemeral.sh' do
  source 'mountEphemeral.sh'
  mode '0755'
end

systemd_unit 'mountEphemeral.service' do
  content(
      Unit: {
          Description: 'Mount ephemeral drive',
          Wants: 'network-online.target',
          After: 'network-online.target',
      },
      Service: {
          Type: 'oneshot',
          ExecStart: '/opt/aws/mountEphemeral.sh',
      },
      Install: {
          WantedBy: 'multi-user.target',
      })
  action [ :create, :enable ]
end
