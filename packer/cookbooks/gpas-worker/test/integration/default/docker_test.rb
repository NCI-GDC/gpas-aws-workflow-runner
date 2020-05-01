# InSpec test for recipe gpas-worker::slurm

# The InSpec reference, with examples and extensive documentation, can be
# found at https://www.inspec.io/docs/reference/resources/

describe docker.version do
  its('Server.Version') { should cmp >= '1.18' }
  its('Client.Version') { should cmp >= '1.18' }
end
