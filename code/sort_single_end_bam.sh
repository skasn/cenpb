#!/bin/bash

# Sort and index a single-ended alignment SAM/BAM

#SBATCH -n 1
#SBATCH --cpus-per-task=1
#SBATCH --time=5:00:00

FN=$1

PFX=${FN%.*}
FEXT=${FN##*.}

if [ "${FEXT}" == "bam" ]; then
    samtools sort ${FN} > ${PFX}.sorted.bam
    mv ${PFX}.sorted.bam ${FN}
    samtools index ${FN}
else
    samtools view -bS ${FN} | samtools sort -o ${PFX}.bam -
    rm ${FN}
    samtools index ${PFX}.bam
fi

echo "JOB DONE."
