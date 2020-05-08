#!/bin/bash 
set -x

BUCKET_NAME=uchig-genomics-pipeline-us-east-1
DOWNLOAD_PATH=/mnt/SCRATCH/reference/hwf/
INPUT_FILES="
CNV_SV_ref_GRCh38_hla_decoy_ebv_brass6.tar.gz
CosmicCombined.srt.vcf.gz
CosmicCombined.srt.vcf.gz.tbi
GRCh38.d1.vd1.dict
GRCh38.d1.vd1.fa
GRCh38.d1.vd1.fa.amb
GRCh38.d1.vd1.fa.ann
GRCh38.d1.vd1.fa.bwt
GRCh38.d1.vd1.fa.fai
GRCh38.d1.vd1.fa.pac
GRCh38.d1.vd1.fa.sa
Homo_sapiens_assembly38.known_indels.vcf.gz
Homo_sapiens_assembly38.known_indels.vcf.gz.tbi
MuTect2.PON.4136.vcf.gz
MuTect2.PON.4136.vcf.gz.tbi
SNV_INDEL_ref_GRCh38_hla_decoy_ebv-fragment.tar.gz
af-only-gnomad-biallelic-autoallo.hg38.vcf.gz
af-only-gnomad-biallelic-autoallo.hg38.vcf.gz.tbi
core_ref_gdc_cgp.tar.gz
dbsnp_144.hg38.vcf.gz
dbsnp_144.hg38.vcf.gz.tbi
gdc_vagrent_homo_sapiens_core_80_38.tar.gz
gencode.v22.annotation.genePred
gencode.v22.annotation.rRNA.transcript.list
qcGenotype_GRCh38_hla_decoy_ebv.tar.gz
star2.7.0f-GRCh38.d1.vd1-gtfv22.tar.gz"

mkdir -p $DOWNLOAD_PATH

for file in $INPUT_FILES
do
	aws s3 cp s3://$BUCKET_NAME/reference/${file} $DOWNLOAD_PATH/${file}
done
