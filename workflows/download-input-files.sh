#!/bin/bash 
set -x

BUCKET_NAME=bio-performance-test
DOWNLOAD_PATH=/mnt/SCRATCH/reference/hwf/
INPUT_FILES="GRCh38.d1.vd1.dict
GRCh38.d1.vd1.fa
GRCh38.d1.vd1.fa.amb
GRCh38.d1.vd1.fa.ann
GRCh38.d1.vd1.fa.bwt
GRCh38.d1.vd1.fa.fai
GRCh38.d1.vd1.fa.pac
GRCh38.d1.vd1.fa.sa
af-only-gnomad-biallelic-autoallo.hg38.vcf.gz
af-only-gnomad-biallelic-autoallo.hg38.vcf.gz.tbi
dbsnp_144.hg38.vcf.gz
dbsnp_144.hg38.vcf.gz.tbi"

mkdir -p $DOWNLOAD_PATH

for file in $INPUT_FILES
do
	aws s3 cp s3://$BUCKET_NAME/${file} $DOWNLOAD_PATH/${file}
done
