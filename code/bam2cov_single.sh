#!/bin/bash

#SBATCH -n 1
#SBATCH --cpus-per-task=1
#SBATCH --time=10:00:00

BAM=$1
GSIZES=$2

if [ ! -z $3 ]; then
    REND=$3
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

bedtools genomecov -bg ${FLAG} -ibam ${BAM} -g ${GSIZES}\
 > ${OUT}

echo "JOB DONE."
