# InSpec test for recipe gpas-worker::default

# The InSpec reference, with examples and extensive documentation, can be
# found at https://www.inspec.io/docs/reference/resources/

describe package('unzip') do
  it { should be_installed }
end

describe command('aws help') do
  its('exit_status') { should eq 0 }
end
