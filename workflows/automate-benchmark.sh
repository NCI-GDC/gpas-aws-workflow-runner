#! /bin/bash

filename=COLO-829-BL

# install needed packages
sudo yum update -y
sudo yum install git -y
sudo yum install jq -y

# Mount the working EBS
sudo mkdir -p /mnt
#sudo file -s /dev/nvme1n1
sudo mkfs -t xfs /dev/nvme1n1
sudo mount /dev/nvme1n1 /mnt
sudo cp /etc/fstab /etc/fstab.orig
uuid=`sudo blkid -s UUID -o value /dev/nvme1n1`
echo "UUID=$uuid  /mnt  xfs  defaults,nofail  0  2" | sudo tee -a /etc/fstab

# Make the working mount usable by this everyone
sudo chmod 777 /mnt
mkdir -p /mnt/SCRATCH

# get the workflow scripts
git clone -b feat/BINF-309 https://github.com/NCI-GDC/gdc-dnaseq-cwl.git
git clone https://github.com/NCI-GDC/gpas-aws-workflow-runner.git

# configure docker to use the working disk and allow non-root usage
mkdir -p /mnt/SCRATCH/docker-data
sudo bash -c 'echo DOCKER_OPTS=\"-g /mnt/SCRATCH/docker-data/\" >> /etc/default/docker'
sudo service docker restart
sudo gpasswd -a $USER docker

# run the workflow and profile it
{
  # get the needed input data
  cd gpas-aws-workflow-runner/workflows/

  # pull reference files
  python input_mapping/files-to-download.py reference_files "DNA-Seq alignment" | xargs -i  aws s3 cp {} /mnt/SCRATCH/files/

  # pull input bam/bai pair
  python input_mapping/files-to-download.py input_bam_files "WGS-hello-world" | grep $filename | xargs -i aws s3 cp {} /mnt/SCRATCH/files/

  # pack the workflow
  ./pack-workflow.sh $HOME/gdc-dnaseq-cwl/workflows/main/gdc_dnaseq_main_workflow.cwl

  # adjust the thread_count in job inputs to the actual vCPU of the EC2
  cpucount=`nproc`
  cd $HOME/gpas-aws-workflow-runner/workflows/tasks/WGS-hello-world
  jq --argjson a $cpucount '.thread_count = $a' wgs.hello-world.input.json > tmp.json && mv tmp.json wgs.hello-world.input.json

  sed -i 's|{PATH_TO}|/mnt/SCRATCH/files|' wgs.hello-world.input.json

  cd /mnt/SCRATCH

  # login to Quay using an encrypted passwd
  docker login -u="$QUAY_USERNAME" -p="$QUAY_PASSWORD" quay.io

  # write out the current time
  date > "start-time.txt"

  #profile system activity and extended disk access info every 60 seconds
  /usr/lib64/sa/sadc -F -S XDISK 60 ./sa.log &
  sadc_pid=$!

  # time the job (we use gnu time /usr/bin/time rather than the bash built in)
  /usr/bin/time -v -o "time.txt" $HOME/gpas-aws-workflow-runner/workflows/run-workflow.sh $HOME/gpas-aws-workflow-runner/workflows/tasks/WGS-hello-world/wgs.hello-world.input.json &> log.txt
}

# run at the end to dump out logs to s3 and then shut down
{
  summary_bucket_path="s3://uchig-genomics-pipeline-us-east-1/benchmarks"
  benchmark_name="gdc_dnaseq_main_workflow"
  TOKEN=`curl --silent -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
  instance_type=`curl -H "X-aws-ec2-metadata-token: $TOKEN" --silent http://169.254.169.254/latest/meta-data/instance-type`
  instance_id=`curl -H "X-aws-ec2-metadata-token: $TOKEN" --silent http://169.254.169.254/latest/meta-data/instance-id`

  # stop the sadc process we started
  kill -SIGINT $sadc_pid

  # get the formatted sar report
  sadf -p -- -A sa.log | gzip > sar.txt.gz

  s3_path="${summary_bucket_path}/${benchmark_name}/${instance_type}/${instance_id}"

  # copy sar.txt.gz report to s3
  aws s3 --no-progress cp ./sar.txt.gz "${s3_path}/sar.txt.gz"
  # copy sar binary data to s3
  aws s3 --no-progress cp ./sa.log "${s3_path}/sa.log"
  # zip and copy log.txt to s3
  gzip -f log.txt
  aws s3 --no-progress cp ./log.txt.gz "${s3_path}/log.txt.gz"
  #copy start-time.txt to s3
  aws s3 --no-progress cp ./start-time.txt "${s3_path}/start-time.txt"
  #copy time.txt to s3
  aws s3 --no-progress cp ./time.txt "${s3_path}/time.txt"

  sleep 60
  sudo shutdown
}
