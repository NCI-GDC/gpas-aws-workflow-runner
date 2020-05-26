#! /bin/bash

# install needed packages
yum update -y
yum install git -y
yum install jq -y

# Mount the working EBS
mkdir -p /mnt
#sudo file -s /dev/nvme1n1
mkfs -t xfs /dev/nvme1n1
mount /dev/nvme1n1 /mnt
cp /etc/fstab /etc/fstab.orig
uuid=`blkid -s UUID -o value /dev/nvme1n1`
echo "UUID=$uuid  /mnt  xfs  defaults,nofail  0  2" | tee -a /etc/fstab

mkdir -p /mnt/SCRATCH

# configure docker to use the working disk and allow non-root usage
mkdir -p /mnt/SCRATCH/docker-data
bash -c 'echo DOCKER_OPTS=\"-g /mnt/SCRATCH/docker-data/\" >> /etc/default/docker'
service docker restart
gpasswd -a ec2-user docker

# Make the working mount usable by everyone
chmod 777 -R /mnt
aws s3 cp s3://uchig-genomics-pipeline-us-east-1/benchmarks/dna-seq.sh /home/ec2-user/dna-seq.sh
chmod a+x /home/ec2-user/dna-seq.sh

sudo -i -u ec2-user ./dna-seq.sh &
