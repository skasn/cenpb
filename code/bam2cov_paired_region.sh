#!/bin/bash

#SBATCH -n 1
#SBATCH --cpus-per-task=1
#SBATCH --time=5:00:00

# Get coverage from BAM produced from mapping paired
# end reads; filter by size

# Usage:
# ./bampe_cvg.sh [BAM] [min len] [max len] [sizes file]

# Note: BAM file *MUST* be sorted by name such that paired
# reads are adjacent

# Assume that bedops is in path

BAM=$1
BED=$2
SIZES=$3
MINL=0
MAXL=10000

PFX=${BAM%.*}

OUTFN=${PFX}.cov.bed

if [ ! -z $4 ] && [ ! -z $5 ]; then
    MINL=$4
    MAXL=$5
    OUTFN=${PFX}.len${MINL}-${MAXL}.cov.bed
fi

# Convert BAM to BEDPE, filter on length, compute coverage
# using genomecov
bedtools bamtobed -bedpe -i ${BAM} |\
 bedtools intersect -wo -a - -b ${BED} |\
 awk -v A=${MINL} -v B=${MAXL} \
 '{if ($5-$2>=A && $5-$2<=B) print $1 "\t" $2 "\t" $6}' |\
 sort-bed - > ${PFX}.tmp

bedtools genomecov -bg -i ${PFX}.tmp -g ${SIZES} > ${OUTFN}

rm ${PFX}.tmp
echo "JOB DONE."
