#
# Cookbook:: ec2-slurm-worker
# Recipe:: python
#
# Copyright:: 2020, NCI-GDC, Apache v2.0.

package 'python'

case node['platform']
when 'ubuntu', 'debian'
  if node['virtualization']['system'] == 'vbox'
    user = 'vagrant'
    home_dir = '/home/vagrant'
  else
    user = 'ubuntu'
    home_dir = '/home/ubuntu'
  end
  virtualenwrapper_path = "#{home_dir}/.local/bin/virtualenvwrapper.sh"

  package %w(python-dev python-pip libpq-dev)
when 'amazon'
  user = 'ec2-user'
  home_dir = '/home/ec2-user'

  virtualenwrapper_path = "#{home_dir}/.local/bin/virtualenvwrapper.sh"

  package %w(python-devel python2-pip libpqxx-devel)
else
  user = 'root'
  home_dir = '/root'

  package %w(python python-dev python-pip libpq-dev)

  virtualenwrapper_path = '/usr/bin/virtualenvwrapper.sh'
end

directory "#{home_dir}/.virtualenvs" do
  user user
  group user
end

execute 'Install virtualenv' do
  command 'pip install --user virtualenv'
  environment ({
      'PYTHONUSERBASE' => "#{home_dir}/.local",
  })
  user user
end

execute 'Install virtualenvwrapper' do
  command 'pip install --user virtualenvwrapper'
  environment ({
      'PYTHONUSERBASE' => "#{home_dir}/.local",
  })
  user user
end

bash 'Prepare virtualenv' do
  code <<-EOH
    source #{virtualenwrapper_path}
    mkvirtualenv --python=python2 p2
    pip install --upgrade pip==9.*
  EOH
  environment ({
    'WORKON_HOME' => "#{home_dir}/.virtualenvs",
    'VIRTUALENVWRAPPER_PYTHON' => '/usr/bin/python2',
    'VIRTUALENVWRAPPER_VIRTUALENV' => "#{home_dir}/.local/bin/virtualenv",
    'PYTHONUSERBASE' => "#{home_dir}/.local",
  })
  user user
end

bash 'Update bashrc' do
  user user
  code <<-EOS
    echo "source #{virtualenwrapper_path}" >> #{home_dir}/.bashrc
  EOS
  not_if "grep -q virtualenvwrapper.sh #{home_dir}/.bashrc"
end

%w(SQLAlchemy psycopg2 awscli==1.10.14 pysam==0.15.2 cwltool==1.0.20180306163216).each do |package|
  execute "Install #{package}" do
    command "#{home_dir}/.virtualenvs/p2/bin/pip install #{package}"
    user user
  end
end
