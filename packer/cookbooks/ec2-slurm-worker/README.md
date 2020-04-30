# ec2-slurm-worker

Multi-platform cookbook to create an image used for Slurm workflows on AWS EC2 instances.

## Supported platforms
* Ubuntu 18.04
* Amazon Linux 2

## Tools and applications
#### Dependencies
##### Docker
### AWS Cloudwatch Logs agent 
### Instance store handling (ephemeral drives)

## Testing
To test locally make certain you have [Virtualbox](https://www.virtualbox.org/wiki/Downloads) and [Chef Workstation](https://downloads.chef.io) installed on your machine. 

### Kitchen
Kitchen allows you to verify your recipes by running them in a VM.
This can be local on Virtualbox or on an Openstack or EC2 machine for example.

The runs and test cases are configured in `kitchen.yml`. Tests are located in `test/integration/default`. 
To expand tests follow the documentation at [InSpec.io](https://www.inspec.io/docs/reference/resources/).

#### Running kitchen
The following commands can be used from the root directory of the cookbook.

As of v1 writing this documentation Kitchen has been configured to test on Ubuntu 18 and Amazon Linux 2. 
When not specifying a platform Kitchen will execute the command for both platforms. 
You can your testing to a specific platform by appending that platform to the command.
For example:

```kitchen test default-ubuntu-1804```

##### Destroying existing VMs
```kitchen destroy```
##### Converging VMs
```kitchen converge```
##### Running tests
```kitchen verify```
##### Running tests on a clean environment
Kitchen `test` will destroy all existing VMs, converge them, run the tests and then destroy
```kitchen test```
##### Logging in to VM
```kitchen login default-ubuntu-1804```

### Linting
#### Cookstyle
A linting tool that helps you to write better Chef Infra cookbooks by detecting and automatically correcting style, syntax, and logic mistakes in your code.
```cookstyle```
