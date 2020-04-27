# GDC Workflow Runner

## Overview 

- GDC workflows are written in Common Workflow Language (CWL), and can be found in the [NCI-GDC github organisation](https://github.com/NCI-GDC/)

- GDC workflows are used for production with the GDC Pipeline Automation System (GPAS). For the 4 workflows that needs to be tested, we created external user entrypoints that can be used independently without GPAS. Check README in each repo for more details.

- GDC workflows load dockers. All external dockers are public, and internal dockers are hosted in quay.io. We have created a quay group to share the required dockers to the APS team for testing purposes. (Will require quay id of AWP team members to add into this group) 

- GDC workflows require input molecular files. Stored in the `gdcbackup` s3 bucket. 

- GDC workflows require other reference files (such as human genome sequence). Stored in the `bio-performance-test` bucket. 

_Figure 1: Overview of GDC workflow_ 
![Figure 1](assets/gdc_workflow_figure.png)

First workflow that we will run will be a DNA-Seq Alignment workflow on a 2.5Gb WGS bam file. 

## Prereqs

- **EC2** instance resources depend on the type of workflow running and the size of the input file. In this(We used c5d.4xlarge):
  - cpus > 4 
  - ram > 12 Gb
  - disk space > 50Gb 
- Access to gdc-dnaseq-cwl workflow in github
- Access to **gdcbackup** and **bio-performance-test** buckets. 
- Requirements on the instance: 
  - awscli
  - docker
  - Access to quay (for docker images)
  - python
  - cwltool
  - nodejs

We have checked in a chef cookbook (gdc-workflow-runner) that can be used to build an AMI that will have all the requirements baked in. You can see 


## Running the workflow 

### Download requirements

Pull the required repositories. 

- The dna-seq alignment workflow

```
git clone -b feat/BINF-309 git@github.com:NCI-GDC/gdc-dnaseq-cwl.git
```

- Scripts to run the workflow 
```
git clone git@github.com:NCI-GDC/gpas-aws-workflow-runner.git
```

- Download all the reference files. By default all files are downloaded to `/mnt/SCRATCH/reference/hwf/`. You can pass a different value in the argument if you like.  
```
cd gpas-aws-workflow-runner/workflows/
./download-input-files.sh
```

- Pack the cwlworkflow into a json. We use this internally to pass it as a payload. 
```
./pack-workflow.sh /path/to/gdc-dnaseq-cwl/workflows/main/gdc_dnaseq_main_workflow.cwl
```

- Download the input bam file file. 
```
aws s3 cp --request-payer requester s3://gdcbackup/4a43affb-57a2-4fc6-a483-96716511ab5e/A77474_1_lane_dupsFlagged.bam .
```

- Edit `input.json` to update the location of the input and reference files. 
  - We saved the input file at `/mnt/SCRATCH/playground/benchmark/BINF-308/wgs/A77474_1_lane_dupsFlagged.bam` but it can be anywhere really. 
  - We saved the reference files under `/mnt/SCRATCH/reference/hwf/`

### Run workflow

- Run the script in a directory where you want to store the output file.  
```
$ df -h /mnt
/dev/nvme0n1    366G   57G  310G  16% /mnt

cd /mnt/SCRATCH
```

- Run the script 
```
/home/ubuntu/gpas-aws-workflow-runner/workflows/run-workflow.sh
```