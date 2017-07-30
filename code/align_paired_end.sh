#!/bin/bash

#SBATCH -n 1
#SBATCH --time=10:00:00

# Align a supplied paired FASTQ file (can be pattern) to
# specified index using bowtie2; output is BAM formatted
# (sorted and indexed)

FQ1=(`ls $1`)
FQ2=(`ls $2`)
IDX=$3
OUTNAME=`basename ${FQ1%.*}`
OUTNAME=${OUTNAME}.bam
NPROC=1

if [[ ! -z $4 ]]; then
    OUTNAME=$4
    OUTEXT=${OUTNAME##*.}}
    if [[ ${OUTEXT} != "bam" ]]; then
        OUTNAME=${OUTNAME}.bam
    fi
fi

if [[ ! -z $5 ]]; then
    NPROC=$5
fi

MINLEN=10
MAXLEN=700
BT2OPTS="-p ${NPROC} --end-to-end --very-sensitive --no-unal --no-mixed --no-discordant --overlap --dovetail -I ${MINLEN} -X ${MAXLEN}"

module load bowtie2

# Get a comma-separated list of filenames
FQ1L=`ls -m ${FQ1[@]} | tr -d ' ' | tr -d '\n'`
FQ2L=`ls -m ${FQ2[@]} | tr -d ' ' | tr -d '\n'`

bowtie2 ${BT2OPTS} -x ${IDX} -1 ${FQ1L} -2 ${FQ2L}| \
    samtools view -bS - > ${OUTNAME}

sort_paired_end_bam.sh ${OUTNAME}

echo "JOB DONE."
