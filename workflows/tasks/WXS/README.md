## DNA-Seq WXS

This task takes different sized WXS BAM files as input.

The size range is 8-20G.

filename|size
--------|----
C836.MKN74.2.bam|16936446279
C836.MJ.2.bam|10813037067
C836.SNU-1105.1.bam|9037810959
C836.SNU-1066.4.bam|23278762857
C836.FTC-238.1.bam|9218168832
C836.Hs_766T.2.bam|12035042999
C836.PK-1.1.bam|11622512210
C836.HCC1395.2.bam|19016645040
C836.DV-90.1.bam|10190305010
C836.MDA-MB-415.1.bam|9714987738

The example CWL input json is [here](wxs.input.json)
  * Please note the `job uuid` can be any string here. It will be used as a prefix for sqlite db output file.
  * `bam_name` will be used as the output file name.

For the input data, please refer to [input_mapping.json](../../input_mapping/input_mapping.json):
* Input data: `input_mapping["input_bam_files"]["WXS"]`. You can use the following command to download the files locally. Replace `C836.MKN74.2.bam` with the correct bam. This will download a bam/bai pair and save to `/mnt/SCRATCH/files/`

```
{$HOME}/gpas-aws-workflow-runner/workflows# python input_mapping/files-to-download.py input_bam_files "WXS" | grep C836.MKN74.2.bam | xargs -i aws s3 cp {} /mnt/SCRATCH/files/
```
* Reference files: `input_mapping["reference_files"]["DNA-Seq alignment"]`
```
{$HOME}/gpas-aws-workflow-runner/workflows# python input_mapping/files-to-download.py reference_files "DNA-Seq alignment" | xargs -i  aws s3 cp {} /mnt/SCRATCH/files/
```

* Update the file path in input.json.   
```
sed -i 's/{PATH_TO}/\/mnt\/SCRATCH\/files/' tasks/WXS/wxs.input.json
```

To run the GDC DNA-Seq workflow, you would need `Read Group` metadata for each BAM file. These could be found at:
* [C836.MKN74.2.bam](../../readgroup_metadata/WXS/eab21de1-bd9f-4916-a8e6-5b3b8540877b.json)
* [C836.MJ.2.bam](../../readgroup_metadata/WXS/8c3dbcbe-818c-48bb-8105-ea3107999dac.json)
* [C836.SNU-1105.1.bam](../../readgroup_metadata/WXS/a908f78f-fa23-4be2-9b1b-42710a69c1b4.json)
* [C836.SNU-1066.4.bam](../../readgroup_metadata/WXS/380e37b5-f5c5-4dee-ba46-9668fe67c210.json)
* [C836.FTC-238.1.bam](../../readgroup_metadata/WXS/005a752e-cf77-446a-b708-5a28d3a03170.json)
* [C836.Hs_766T.2.bam](../../readgroup_metadata/WXS/0a470930-2ebb-4d7b-a59d-045ed1215fb1.json)
* [C836.PK-1.1.bam](../../readgroup_metadata/WXS/3a8d9e5f-4390-4754-be9d-5484f9b03b83.json)
* [C836.HCC1395.2.bam](../../readgroup_metadata/WXS/b200ac58-91e1-4a2b-a396-4cc3118f963b.json)
* [C836.DV-90.1.bam](../../readgroup_metadata/WXS/232aada6-2001-4359-880a-e630f4287b59.json)
* [C836.MDA-MB-415.1.bam](../../readgroup_metadata/WXS/9efa8d39-37e0-4236-9737-e14ddcfd93ff.json)

The read group metadata json is named by the UUID. You could also use [url_uuid_mapping.json](../../input_mapping/url_uuid_mapping.tsv) to map the filename with the uuid. </br>

The read group metadata would need to be changed at the following section accordingly in the CWL input json:

`cwl_input["readgroups_bam_file_list"]["readgroup_meta_list"]`

To test [DNA-Seq WXS somatic variant calling](../../tasks/WXS-variant-calling/README.md), we would like to complete all these 10 WXS BAM files. </br>
Use [C836.MJ.2.bam](../../readgroup_metadata/WXS/8c3dbcbe-818c-48bb-8105-ea3107999dac.json) as normal sample, the rest 9 BAM files as tumor sample.

* Normal: `C836.MJ.2.bam`
* Tumor:
  * `C836.MKN74.2.bam`
  * `C836.SNU-1105.1.bam`
  * `C836.SNU-1066.4.bam`
  * `C836.FTC-238.1.bam`
  * `C836.Hs_766T.2.bam`
  * `C836.PK-1.1.bam`
  * `C836.HCC1395.2.bam`
  * `C836.DV-90.1.bam`
  * `C836.MDA-MB-415.1.bam`

```
vi tasks/WXS/wxs.input.json # and update readgroup_meta_list 
```