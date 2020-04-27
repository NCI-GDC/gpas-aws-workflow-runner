#
# Cookbook:: gdc-workflow-runner
# Recipe:: default
#
# Copyright:: 2020, NCI-GDC, Apache v2.0.

include_recipe 'gdc-workflow-runner::os_base'
include_recipe 'gdc-workflow-runner::python'
include_recipe 'gdc-workflow-runner::docker'
include_recipe 'gdc-workflow-runner::nodejs'
