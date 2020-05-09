# GDC Workflow Runner

## Overview

- GDC workflows are written in Common Workflow Language (CWL), and can be found in the [NCI-GDC github organisation](https://github.com/NCI-GDC/)

- GDC workflows are used for production with the GDC Pipeline Automation System (GPAS). For the 4 workflows that needs to be tested, we created external user entrypoints that can be used independently without GPAS. Check README in each repo for more details.
  - [DNA alignment](https://github.com/NCI-GDC/gdc-dnaseq-cwl/tree/feat/BINF-309)
    - To convert user submitted DNA-Seq (WGS, WXS) BAM files into a GDC re-alignment BAM file.
    - Some other files such as BAI file, and alignment metrics are also generated.
  - [WGS variant calling](https://github.com/NCI-GDC/gdc-sanger-somatic-cwl)
    - To accept a pair of tumor and normal WGS BAM files, and derive somatic mutation in VCF/ TSV/ PEDPE, and other outputs.
  - [WXS variant calling](https://github.com/NCI-GDC/gdc-somatic-variant-calling-workflow)
    - To accept a pair of tumor and normal WXS BAM files, and derive somatic mutations in VCF, and other outputs.
  - [RNA alignment](https://github.com/NCI-GDC/gdc-rnaseq-cwl/tree/feat/etl)
    - To accept BAM or FASTQ inputs, and derive 3 different BAMs, quantification TSV, spliceJunction TSV, and other outputs.

- GDC workflows load dockers. All external dockers are public, and internal dockers are hosted in quay.io. We have created a quay group to share the required dockers to the APS team for testing purposes. (Will require quay id of AWP team members to add into this group)

- GDC workflows require input molecular files. Stored in the `uchig-genomics-pipeline-us-east-1` s3 bucket.

- GDC workflows require other reference files (such as human genome sequence). Also stored in the `uchig-genomics-pipeline-us-east-1` bucket.

_Figure 1: Overview of GDC workflow_
![Figure 1](assets/gdc_workflow_figure.png)

First workflow that we will run will be a DNA-Seq Alignment workflow on a 2.5Gb WGS bam file.

## Prereqs

- **EC2** instance resources depend on the type of workflow running and the size of the input file. In this(We used c5d.4xlarge):
  - cpus > 4
  - ram > 12 Gb
  - disk space > 50Gb
- Access to gdc-dnaseq-cwl workflow in github
- Access to **uchig-genomics-pipeline-us-east-1** buckets.
- Requirements on the instance:
  - awscli
  - docker
  - Access to quay (for docker images)
  - python
  - cwltool
  - nodejs

We have checked in a chef cookbook (gpas-worker) that can be used to build an AMI that will have all the requirements baked in. You can find the instructions [here](packer/README.md).


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

```
cd gpas-aws-workflow-runner/workflows/
./download-input-files.sh
```

- Pack the cwlworkflow into a json. We use this internally to pass it as a payload.
```
./pack-workflow.sh /path/to/gdc-dnaseq-cwl/workflows/main/gdc_dnaseq_main_workflow.cwl
```

- Download the input bam file and its index file.
```
aws s3 cp s3://uchig-genomics-pipeline-us-east-1/bioinformatics_scratch/shenglai/binf389/COLO-829.bam .
aws s3 cp s3://uchig-genomics-pipeline-us-east-1/bioinformatics_scratch/shenglai/binf389/COLO-829.bai .

```

- Edit [WGS-hello-world.input.json](workflows/example_input_json/WGS-hello-world/wgs.hello-world.input.json) to update the placeholder of the input and reference files.

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


### Tasks and Data

For different tasks (workflows), please check the [Input mapping json](workflows/input_mapping/input_mapping.json).

For readgroup metadata, the mapping could be found at the [Read Group mapping tsv](workflows/input_mapping/url_uuid_mapping.tsv). </br>
(The readgroup json is named by the uuid, not the file name.)

#### DNA-Seq WGS (small size, first hello world task)

Example input json is at [here](workflows/example_input_json/WGS-hello-world/wgs.hello-world.input.json).

#### DNA-Seq WGS (decent size)

Example input json is at [here](workflows/example_input_json/WGS/wgs.input.json). </br>

These are all tumor samples. To run the sanger variant calling, we could use the first one as fake normal so that we have 4 pairs.
(`D4491.Solexa-178364.2.bam`)

#### DNA-Seq WXS

Example input json is at [here](workflows/example_input_json/WXS/wxs.input.json). </br>

These are all tumor samples as well. To run the somatic variant calling, we could use the first one as fake normal so that we have 9 pairs.
(`C836.MKN74.2.bam`)


#### RNA-Seq

Example input json is at [here](workflows/example_input_json/RNA/rna.input.json). </br>


#### DNA-Seq WGS Sanger somatic variant calling

Example input json is at [here](workflows/example_input_json/WGS-Sanger/wgs.sanger.input.json). </br>


#### DNA-Seq WXS somatic variant calling

Example input json is at [here](workflows/example_input_json/WXS-variant-calling/wxs.variant-calling.input.json). </br>


