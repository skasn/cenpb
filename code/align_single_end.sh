#!/bin/bash

#SBATCH -n 1
#SBATCH --time=10:00:00

# Align a supplied FASTQ file (can be pattern) to
# specified index using bowtie2; output is BAM formatted
# (sorted and indexed)

FQ=(`ls $1`)
IDX=$2
OUTNAME=`basename ${FQ%.*}`
OUTNAME=${OUTNAME}.bam
NPROC=1

if [[ ! -z $3 ]]; then
    OUTNAME=$3
    OUTEXT=${OUTNAME##*.}}
    if [[ ${OUTEXT} != "bam" ]]; then
        OUTNAME=${OUTNAME}.bam
    fi
fi

if [[ ! -z $4 ]]; then
    NPROC=$4
fi

BT2OPTS="--very-sensitive -p ${NPROC} --no-unal --non-deterministic"

module load bowtie2

# Get a comma-separated list of filenames
FQL=`ls -m ${FQ[@]} | tr -d ' ' | tr -d '\n'`

bowtie2 ${BT2OPTS} -x ${IDX} -U ${FQL} | \
    samtools view -bS - > ${OUTNAME}

# Sort and index the bam file
sort_single_end_bam.sh ${OUTNAME}

echo "JOB DONE."
