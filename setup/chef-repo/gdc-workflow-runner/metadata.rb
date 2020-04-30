  
name 'gdc-workflow-runner'
maintainer 'NCI-GDC'
maintainer_email 'support@nci-gdc.datacommons.io'
license 'Apache-2.0'
description 'Installs/Configures gdc-workflow-runner'
version '0.1.0'
chef_version '>= 14.0'

source_url 'https://github.com/NCI-GDC/gpas-worker'
issues_url 'https://github.com/NCI-GDC/gpas-worker/issues'

supports 'ubuntu', '>= 18.04'
supports 'amazon', '= 2'

depends 'apt', '~> 7.2.0'
depends 'yum-epel'
depends 'os-hardening'

depends 'ark', '~> 5.0.0'
depends 'logrotate', '~> 2.2.2'
depends 'hostsfile', '~> 3.0.1'
