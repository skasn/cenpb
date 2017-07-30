#!/bin/bash

# Sort and index a paired-ended alignment SAM/BAM;
# this is a sort by name

#SBATCH -n 1
#SBATCH --cpus-per-task=1
#SBATCH --time=5:00:00

FN=$1

PFX=${FN%.*}
FEXT=${FN##*.}

if [ "${FEXT}" == "bam" ]; then
    samtools sort -n ${FN} > ${PFX}.sorted.bam
    mv ${PFX}.sorted.bam ${FN}
else
    samtools view -bS ${FN} | samtools sort -n -o ${PFX}.bam -
    rm ${FN}
fi

echo "JOB DONE."
