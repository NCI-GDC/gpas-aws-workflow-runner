#
# Cookbook:: ec2-slurm-worker
# Spec:: default
#
# Copyright:: 2020, NCI-GDC, Apache v2.0.

require 'spec_helper'

describe 'ec2-slurm-worker::default' do
  context 'When all attributes are default, on Ubuntu 18.04' do
    # for a complete list of available platforms and versions see:
    # https://github.com/chefspec/fauxhai/blob/master/PLATFORMS.md
    platform 'ubuntu', '18.04'

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end

  context 'When all attributes are default, on Amazon Linux 2' do
    # for a complete list of available platforms and versions see:
    # https://github.com/chefspec/fauxhai/blob/master/PLATFORMS.md
    platform 'amazon', '2'

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end
end
