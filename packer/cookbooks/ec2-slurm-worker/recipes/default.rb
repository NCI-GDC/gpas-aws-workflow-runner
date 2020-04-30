#
# Cookbook:: ec2-slurm-worker
# Recipe:: default
#
# Copyright:: 2020, NCI-GDC, Apache v2.0.

include_recipe 'ec2-slurm-worker::os_base'
include_recipe 'ec2-slurm-worker::python'
include_recipe 'ec2-slurm-worker::docker'
include_recipe 'ec2-slurm-worker::nodejs'