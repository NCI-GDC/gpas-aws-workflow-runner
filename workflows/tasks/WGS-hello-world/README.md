## DNA-Seq WGS hello world

Get rna-seq workflow
```
git clone -b feat/BINF-309 git@github.com:NCI-GDC/gdc-dnaseq-cwl.git
```

Pack workflow
```
~/gpas-aws-workflow-runner/workflows$ ./pack-workflow.sh ~/gdc-dnaseq-cwl/workflows/main/gdc_dnaseq_main_workflow.cwl
```

This task takes small-sized BAM files as input, and expects a relative short time to complete.

The example CWL input json is [here](wgs.hello-world.input.json)
  * Please note the `job uuid` can be any string here. It will be used as a prefix for sqlite db output file.
  * `bam_name` will be used as the output file name.

For the input data, please refer to [input_mapping.json](../../input_mapping/input_mapping.json):
* Input data: `input_mapping["input_bam_files"]["WGS-hello-world"]`. You can use the following command to download the files locally. Replace `COLO-829` with the correct bam. This will download a bam/bai pair and save to `/mnt/SCRATCH/files/`

```
{$HOME}/gpas-aws-workflow-runner/workflows# python input_mapping/files-to-download.py input_bam_files "WGS-hello-world" | grep COLO-829 | xargs -i aws s3 cp {} /mnt/SCRATCH/files/
```
* Reference files: `input_mapping["reference_files"]["DNA-Seq alignment"]`
```
{$HOME}/gpas-aws-workflow-runner/workflows# python input_mapping/files-to-download.py reference_files "DNA-Seq alignment" | xargs -i  aws s3 cp {} /mnt/SCRATCH/files/
```

* Update the file path in input.json.   
```
sed -i 's/{PATH_TO}/\/mnt\/SCRATCH\/files/' tasks/WGS-hello-world/wgs.hello-world.input.json
```


To run the GDC DNA-Seq workflow, you would need `Read Group` metadata for each BAM file. These could be found at:
* [COLO-829.bam](../../readgroup_metadata/WGS-hello-world/COLO-829.json)
* [COLO-829-BL.bam](../../readgroup_metadata/WGS-hello-world/COLO-829-BL.json)

The read group metadata would need to be changed at the following section accordingly in the CWL input json:

`cwl_input["readgroups_bam_file_list"]["readgroup_meta_list"]`

As this pair of WGS BAM is relative small, you could use this pair to first test [DNA-Seq WGS Sanger variant calling](../../tasks/WGS-Sanger/README.md).

* Normal: `COLO-829-BL.bam`
* Tumor: `COLO-829.bam`

```
vi tasks/WGS-hello-world/wgs.hello-world.input.json # and update readgroup_meta_list 
```

* Run workflow 
```
mkdir -p /mnt/SCRATCH/runs/dna-seq-wgs-hw/run1/
cd /mnt/SCRATCH/runs/dna-seq-wgs-hw/run1/
time $HOME/gpas-aws-workflow-runner/workflows/run-workflow.sh $HOME/gpas-aws-workflow-runner/workflows/tasks/WGS-hello-world/wgs.hello-world.input.json |& tee -a run.log
```