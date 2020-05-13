## RNA-Seq

This task takes different sized RNA-Seq BAM files as input.

The size range is 12-20G.

filename|size
--------|----
G27518.SK-N-FI.2.bam|19535760450
G27275.TE-9.1.bam|15196620427
G27349.CJM.1.bam|20302253981
G28588.NCI-H1915.1.bam|17672290930
G27381.CAL-33.1.bam|22188061451
G27368.COLO-320.1.bam|18439205374
G28831.J82.3.bam|13157781195
G27277.OVSAHO.1.bam|13432881676
G25210.NCI-H510.1.bam|14671152886
G27495.SNU-1079.2.bam|17759942243

The example CWL input json is [here](rna.input.json)
  * Please note the `job uuid` can be any string here. It will be used as a prefix for output file.

For the input data, please refer to [input_mapping.json](../../input_mapping/input_mapping.json):
* Reference files: `input_mapping["reference_files"]["RNA-Seq alignment"]`
* Input data: `input_mapping["input_bam_files"]["RNA-Seq"]`

To run the GDC RNA-Seq workflow, you would need `Read Group` metadata for each BAM file. These could be found at:
* [G27518.SK-N-FI.2.bam](../../readgroup_metadata/RNA/e8385ceb-1e07-4176-8b80-4f9e75531007.json)
* [G27275.TE-9.1.bam](../../readgroup_metadata/RNA/82ffe43f-314e-474b-afe8-cb3a5d472743.json)
* [G27349.CJM.1.bam](../../readgroup_metadata/RNA/9cc8608b-cfaf-4598-9814-4ef8b6905460.json)
* [G28588.NCI-H1915.1.bam](../../readgroup_metadata/RNA/47b982b3-c7ce-4ca7-8c86-c71c15979620.json)
* [G27381.CAL-33.1.bam](../../readgroup_metadata/RNA/6630e532-e3e7-43c5-bfff-78d60d0ff3cf.json)
* [G27368.COLO-320.1.bam](../../readgroup_metadata/RNA/8322e710-cd45-4e2d-89d5-e6118db78af8.json)
* [G28831.J82.3.bam](../../readgroup_metadata/RNA/1dc5aa91-51d0-4108-930b-2776135ed6aa.json)
* [G27277.OVSAHO.1.bam](../../readgroup_metadata/RNA/b0912b5d-2b20-418c-88c8-eb6ff61275f8.json)
* [G25210.NCI-H510.1.bam](../../readgroup_metadata/RNA/18004fb1-89a2-4ba1-a321-a0aa854e98c3.json)
* [G27495.SNU-1079.2.bam](../../readgroup_metadata/RNA/5aa5d841-f357-45c2-a40a-ad5d9cdd9ed1.json)

The read group metadata json is named by the UUID. You could also use [url_uuid_mapping.json](../../input_mapping/url_uuid_mapping.tsv) to map the filename with the uuid. </br>

The read group metadata would need to be changed at the following section accordingly in the CWL input json:

`cwl_input["readgroups_bam_file_list"]["readgroup_meta_list"]`
