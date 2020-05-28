#! /bin/bash
workflow=${1:-DNA-Seq-WXS}
filename=${2:-COLO-829-BL}

# install needed packages
distro=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
if [[ "$distro" == "\"Ubuntu\"" ]]
then
  sudo apt update -y
  sudo apt install git jq -y
else
  sudo yum update -y
  sudo yum install git -y
  sudo yum install jq -y
fi

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

# get workflow runner code
git clone -b aws-automate https://github.com/NCI-GDC/gpas-aws-workflow-runner.git

# get the workflow scripts
case "$workflow" in
  DNA-Seq-WXS)
      input_mapping_refname="DNA-Seq alignment"
      input_mapping_inputname="WXS"
      cwl_file=gdc-dnaseq-cwl/workflows/main/gdc_dnaseq_main_workflow.cwl
      input_json=WXS/wxs.input.json
      readgroup_dir=WXS
      git clone -b feat/BINF-309 https://github.com/NCI-GDC/gdc-dnaseq-cwl.git
      ;;
  DNA-Seq-WGS)
      input_mapping_refname="DNA-Seq alignment"
      input_mapping_inputname="WGS"
      cwl_file=gdc-dnaseq-cwl/workflows/main/gdc_dnaseq_main_workflow.cwl
      input_json=WGS/wgs.input.json
      readgroup_dir=WGS
      git clone -b feat/BINF-309 https://github.com/NCI-GDC/gdc-dnaseq-cwl.git
      ;;
  RNA-Seq)
      input_mapping_refname="RNA-Seq alignment"
      input_mapping_inputname="RNA-Seq"
      cwl_file=gdc-rnaseq-cwl/workflows/subworkflows/gdc_rnaseq_main_workflow.cwl
      input_json=RNA/rna.input.json
      readgroup_dir=RNA
      git clone -b feat/etl https://github.com/NCI-GDC/gdc-rnaseq-cwl.git 
      ;;
  DNA-Seq-WGS-Sanger)
      input_mapping_refname="WGS Sanger"
      input_mapping_inputname="WGS-Sanger"
      cwl_file=gdc-sanger-somatic-cwl/workflows/subworkflows/main_gdc_wgs_workflow.cwl
      input_json=WGS-Sanger/wgs.sanger.input.json
      readgroup_dir=
      git clone https://github.com/NCI-GDC/gdc-sanger-somatic-cwl.git 
      ;;
  DNA-Seq-WXS-Somatic)
      input_mapping_refname="WXS somatic variant calling"
      input_mapping_inputname="WXS-Somatic"
      cwl_file=gdc-somatic-variant-calling-workflow/workflows/gdc-somatic-variant-calling-workflow.cwl
      input_json=WXS-variant-calling/wxs.variant-calling.input.json
      readgroup_dir=
      git clone https://github.com/NCI-GDC/gdc-somatic-variant-calling-workflow.git --recursive
      ;;
  *)
      echo "Incorrect workflow provided."
      exit 1
esac

# configure docker to use the working disk and allow non-root usage
mkdir -p /mnt/SCRATCH/docker-data
sudo bash -c 'echo DOCKER_OPTS=\"-g /mnt/SCRATCH/docker-data/\" >> /etc/default/docker'
sudo service docker restart
sudo gpasswd -a $USER docker

# run the workflow and profile it
{
  # get the needed input data
  pushd gpas-aws-workflow-runner/workflows/

  # pull reference files
  python input_mapping/files-to-download.py reference_files "$input_mapping_refname" | xargs -i  aws s3 cp {} /mnt/SCRATCH/files/

  # pull input bam/bai pair
  python input_mapping/files-to-download.py input_bam_files "$input_mapping_inputname" | grep $filename | xargs -i aws s3 cp {} /mnt/SCRATCH/files/

  # extract star repo for RNA-Seq
  [[ "$workflow" == "RNA-Seq" ]] && pushd /mnt/SCRATCH/files && tar -xvf star2.7.0f-GRCh38.d1.vd1-gtfv22.tar.gz && popd

  # pack the workflow
  ./pack-workflow.sh $HOME/$cwl_file

  # use tmpfile to create new json
  tmpfile=$(mktemp /tmp/input.json.XXXXXX)

  # adjust the thread_count in job inputs to the actual vCPU of the EC2
  cpucount=`nproc`

  if [[ "$workflow" == "DNA-Seq-WGS-Sanger" ]]; then
    sanger_threads=$(($cpucount - 2))
    fourth=$(echo "$cpucount/4"| bc)
    [[ $fourth -gt 8 ]] && other_threads=8 || other_threads=$fourth
    echo $sanger_threads $other_threads tasks/$input_json
    # update json
    jq --argjson sanger_threads $sanger_threads --argjson other_threads $other_threads \
                           '.sanger_threads = $sanger_threads | 
                            .other_threads = $other_threads' tasks/$input_json > $tmpfile

    # update path and move to original location
    sed -i 's|{PATH_TO}|/mnt/SCRATCH/files|' $tmpfile
  elif [[ "$workflow" == "DNA-Seq-WXS-Somatic" ]]; then
    jq --argjson numcpu $cpucount \
                           '.threads = $numcpu'  tasks/$input_json > $tmpfile 

    # update path and move to original location
    sed -i 's|{PATH_TO}|/mnt/SCRATCH/files|' $tmpfile
  else

    # select readgroup json for inputfile
    readgroup_uuid=$(grep $filename input_mapping/url_uuid_mapping.tsv | awk '{print $2}')
    readgroup_json="$(cat readgroup_metadata/$readgroup_dir/${readgroup_uuid}.json)"

    # update json
    jq --argjson json "$readgroup_json" --argjson numcpu $cpucount --arg bam_name "${filename}" --arg uuid "$readgroup_uuid" \
                      '.readgroup_bam_file_list[0].readgroup_meta_list = $json | 
                       .bam_name = $bam_name |
                       .job_uuid = $uuid |
                       .thread_count = $numcpu' tasks/$input_json > $tmpfile

    # update path and move to original location
    sed -i 's|{PATH_TO}|/mnt/SCRATCH/files|' $tmpfile
    sed -i "s|{FILENAME}|$filename|" $tmpfile
  fi
  # move file to orignal location
  mv $tmpfile input.json 

  # move to directory with enough disk space
  pushd /mnt/SCRATCH

  # login to Quay using an encrypted passwd
  docker login -u="$QUAY_USERNAME" -p="$QUAY_PASSWORD" quay.io

  # write out the current time
  date > "start-time.txt"

  #profile system activity and extended disk access info every 60 seconds
  /usr/lib64/sa/sadc -F -S XDISK 60 ./sa.log &
  sadc_pid=$!

  # time the job (we use gnu time /usr/bin/time rather than the bash built in)
  /usr/bin/time -v -o "time.txt" $HOME/gpas-aws-workflow-runner/workflows/run-workflow.sh $HOME/gpas-aws-workflow-runner/workflows/input.json &> log.txt
}

# run at the end to dump out logs to s3 and then shut down
{
  summary_bucket_path="s3://uchig-genomics-pipeline-us-east-1/benchmarks"
  benchmark_name="${workflow}_${filename}"
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
