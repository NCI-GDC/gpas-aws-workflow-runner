## DNA-Seq WGS

This task takes different large-sized WGS BAM files as input, and expects a relative long time to complete.

The size range is 200-500G.

filename|size
--------|----
D4491.Solexa-178364.2.bam|322760019093
G31860.HCC1954.6.bam|406467012699
G15509.K-562.2.bam|226333347850
G31860.HCC1143.1.bam|385484044509
G15511.HCC1143.2.bam|493624207033

The example CWL input json is [here](wgs.input.json)
  * Please note the `job uuid` can be any string here. It will be used as a prefix for sqlite db output file.
  * `bam_name` will be used as the output file name.

For the input data, please refer to [input_mapping.json](../../input_mapping/input_mapping.json):
* Input data: `input_mapping["input_bam_files"]["WGS"]`. You can use the following command to download the files locally. Replace `D4491.Solexa-178364.2.bam` with the correct bam. This will download a bam/bai pair and save to `/mnt/SCRATCH/files/`.
```
{$HOME}/gpas-aws-workflow-runner/workflows# python input_mapping/files-to-download.py input_bam_files "WGS" | grep D4491.Solexa-178364.2.bam | xargs -i aws s3 cp {} /mnt/SCRATCH/files/
```
* Reference files: `input_mapping["reference_files"]["DNA-Seq alignment"]`
```
{$HOME}/gpas-aws-workflow-runner/workflows# python input_mapping/files-to-download.py reference_files "DNA-Seq alignment" | xargs -i  aws s3 cp {} /mnt/SCRATCH/files/
```


* Update the file path in input.json.   
```
sed -i 's/{PATH_TO}/\/mnt\/SCRATCH\/files/' tasks/WGS/wgs.input.json
```


To run the GDC DNA-Seq workflow, you would need `Read Group` metadata for each BAM file. These could be found at:
* [G31860.HCC1954.6.bam](../../readgroup_metadata/WGS/65381caa-94d6-4a2f-8d1c-a80c6493c401.json)
* [G31860.HCC1143.1.bam](../../readgroup_metadata/WGS/a392a7cb-6edc-4076-93c5-fccb10b01819.json)
* [G15509.K-562.2.bam](../../readgroup_metadata/WGS/b5cc3b41-ce83-478a-a8da-c59cf589077e.json)
* [G15511.HCC1143.2.bam](../../readgroup_metadata/WGS/d41a889a-5eaa-49fd-b92c-68a0b9f07c87.json)
* [D4491.Solexa-178364.2.bam](../../readgroup_metadata/WGS/ee04ea82-3604-4cdd-b2d8-9c8a3de9ba38.json)

The read group metadata json is named by the UUID. You could also use [url_uuid_mapping.json](../../input_mapping/url_uuid_mapping.tsv) to map the filename with the uuid. </br>

The read group metadata would need to be changed at the following section accordingly in the CWL input json:

`cwl_input["readgroups_bam_file_list"]["readgroup_meta_list"]`

To test [DNA-Seq WGS Sanger variant calling](../../tasks/WGS-Sanger/README.md), we would like to complete all these 5 WGS BAM files. </br>
Use [G15509.K-562.2.bam](../../readgroup_metadata/WGS/65381caa-94d6-4a2f-8d1c-a80c6493c401.json) as normal sample, the rest 4 BAM files as tumor sample.

* Normal: `G15509.K-562.2.bam`
* Tumor:
  * `G31860.HCC1143.1.bam`
  * `G31860.HCC1954.6.bam`
  * `G15511.HCC1143.2.bam`
  * `D4491.Solexa-178364.2.bam`
```
vi tasks/WGS/wgs.input.json # and update readgroup_meta_list 
```

