#!/bin/bash



# Take as input a name-sorted BAM file containing alignments
# and a BED file; stream read midpoints and intersect them
# with the BED regions of interest, outputting a BED file
# that can be used to make the v-plot

BAM=$1
BED=$2

VBED=`basename ${BAM%.*}`.`basename ${BED%.*}`.vplot.bed

echo ${VBED}

# Convert BAM to bedpe,
# use awk to make a BED file containing read midpoint and length
# use bedtools intersect to make the vplot BED file, which can then
# be used with a python script to make a vplot

bedtools bamtobed -bedpe -i ${BAM} |\
    awk '{MP=int(($6+$2)/2); print $1 "\t" MP "\t" MP+1 "\t" $7 "\t" $6-$2}' |\
    sort -k1,1 -k2,2n | bedtools intersect -wa -wb -a - -b ${BED} >  ${VBED}

echo "JOB DONE."
