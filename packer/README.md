# GPAS Worker AMI

The EC2 instance where the workflow will run needs to have some packages installed. You can build an AMI using packer which will have all the required pacakges. 

## Install Packer 
Install packer using the instruction [here](https://www.packer.io/intro/getting-started/install.html#precompiled-binaries). 

## Build AMI

- Choose between Amazon Linux and ubuntu 18 images. 

```
cd packer/ubuntu18/
```

- Edit the variables in packer.json according to your AWS configuration. 
```
cat packer.json 
.
.
.
  "variables": {
    "source_ami": "ami-07ebfd5b3428b6f4d",
    "subnet_id": "subnet-0dc5a5bc9b0033a6b",
    "vpc_id": "vpc-099487604cf3c0881",
    "region": "us-east-1",
    "instance_type": "t3.micro",
    "ssh_username": "ubuntu",
    "temporary_security_group_source_cidrs": "172.29.96.0/20,10.64.0.0/18,172.21.0.0/18",
    "ami_name_prefix": "packer-gpas-ubuntu18"
  },
.
.
.
```

- Build ami
```
/path/to/packer build packer.json
```
