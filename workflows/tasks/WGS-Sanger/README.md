## DNA-Seq WGS Sanger variant calling

This task takes the "harmonized" WGS BAM files which are the outputs from the previous run [DNA-Seq WGS](workflows/tasks/WGS/README.md).

It should have 4 pairs with:
* Normal: `G15509.K-562.2.gdc_realn.bam`
* Tumor:
  * `G31860.HCC1143.1.gdc_realn.bam`
  * `G31860.HCC1954.6.gdc_realn.bam`
  * `G15511.HCC1143.2.gdc_realn.bam`
  * `D4491.Solexa-178364.2.gdc_realn.bam`

OR one pair from the hello world test:
* Normal: `COLO-829-BL.gdc_realn.bam`
* Tumor: `COLO-829.gdc_realn.bam`

The example CWL input json is [here](wgs.sanger.input.json)

For the input data, please refer to [input_mapping.json](../../input_mapping/input_mapping.json):
* Reference files: `input_mapping["reference_files"]["WGS Sanger"]`
* Input data: `From previous DNA-Seq WGS alignment.`
  * Please note that the Sanger workflow will need the `.bai` index files generated by the DNA-Seq workflow as well.