## DNA-Seq WGS hello world

This task takes small-sized BAM files as input, and expects a relative short time to complete.

The example CWL input json is [here](wgs.hello-world.input.json)

For the input data, please refer to [input_mapping.json](../../input_mapping/input_mapping.json):
* Reference files: `input_mapping["reference_files"]["DNA-Seq alignment"]`
* Input data: `input_mapping["input_bam_files"]["WGS-hello-world"]`

To run the GDC DNA-Seq workflow, you would need `Read Group` metadata for each BAM file. These could be found at:
* [COLO-829.bam](../../readgroup_metadata/WGS-hello-world/COLO-829.json)
* [COLO-829-BL.bam](../../readgroup_metadata/WGS-hello-world/COLO-829-BL.json)

The read group metadata would need to be changed at the following section accordingly in the CWL input json:

`cwl_input["readgroups_bam_file_list"]["readgroup_meta_list"]`

As this pair of WGS BAM is relative small, you could use this pair to first test [DNA-Seq WGS Sanger variant calling](../../tasks/WGS-Sanger/README.md).

* Normal: `COLO-829-BL.bam`
* Tumor: `COLO-829.bam`
