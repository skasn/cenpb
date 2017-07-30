#!/bin/bash

#SBATCH -n 1
#SBATCH --cpus-per-task=1
#SBATCH --time=10:00:00

BAM=$1
BED=$2
GSIZES=$3

if [ ! -z $4 ]; then
    REND=$4
else
    REND="NONE"
fi

if [ ${REND} == "NONE" ]; then
    OUT=${BAM%.*}.cov.bed
    FLAG=""
else
    OUT=${BAM%.*}.cov.${REND}.bed
    FLAG=-${REND}
fi

bedtools intersect -bed -abam ${BAM} -b ${BED} |\
 bedtools genomecov -bg ${FLAG} -i - -g ${GSIZES}\
 > ${OUT}

echo "JOB DONE."
