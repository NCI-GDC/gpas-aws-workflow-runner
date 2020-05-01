#
# Cookbook:: gpas-worker
# Recipe:: default
#
# Copyright:: 2020, NCI-GDC, Apache v2.0.

include_recipe 'gpas-worker::os_base'
include_recipe 'gpas-worker::python'
include_recipe 'gpas-worker::docker'
include_recipe 'gpas-worker::nodejs'