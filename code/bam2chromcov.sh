#!/bin/bash

# Get per-chromosome coverage from BAM

BAM=$1

samtools view ${BAM} | awk '{print $3}' |\
 sort | uniq -c | awk '{print $2 "\t" $1}' > ${BAM%.*}.cvg

echo "JOB DONE."
