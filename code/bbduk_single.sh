#!/bin/bash

# Quality filter paired reads; assumes bbduk.sh is in path

#SBATCH -n 1
#SBATCH --cpus-per-task=2
#SBATCH --time=10:00:00

R1=$1
MINL=$2

if [ ! -z $3 ]; then
    QUAL=$3
else
    QUAL='auto'
fi

# Minimum quality
MINQ=10   # Minimum quality (for trimming)
MAQ=15    # Minimum average quality
# MINL=85   # Minimum length
NPROC=2   # Number of threads

BBOPTS="t=${NPROC} ftm=5 qtrim=rl trimq=${MINQ}\
 maq=${MAQ} minlen=${MINL} ref=${ADAPT} qin=${QUAL}"

INFQ="in=${R1}"

ACC=${R1%%.*}
OUTFQ="out=${ACC}.filtered.fastq.gz"

(bbduk.sh ${INFQ} ${OUTFQ} ${BBOPTS}) &> ${ACC}.trim.log

echo "JOB DONE."
