#!/bin/bash

# Get a BED file of all reads overlapping a region
# (to be used for making average plots)

BAM=$1
BED=$2

ABED=`basename ${BAM%.*}`.`basename ${BED%.*}`.avg.bed

echo ${ABED}

IOPTS="-bed -wa -wb"

bedtools intersect ${IOPTS} -abam ${BAM} -b ${BED} > ${ABED}

 echo "JOB DONE."
