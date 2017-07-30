#!/bin/bash

# Quality filter paired reads; assumes bbduk.sh is in path

#SBATCH -n 1
#SBATCH --cpus-per-task=2
#SBATCH --time=10:00:00

R1=$1
R2=$2
MINL=$3

# Minimum quality
MINQ=10   # Minimum quality (for trimming)
MAQ=15    # Minimum average quality
# MINL=85   # Minimum length
NPROC=2   # Number of threads

BBOPTS="t=${NPROC} ftm=5 qtrim=rl trimq=${MINQ} maq=${MAQ} minlen=${MINL} ref=${ADAPT}"

INFQ="in1=${R1} in2=${R2}"

ACC=${R1%_*}
OUTFQ="out1=${ACC}_1.filtered.fastq.gz out2=${ACC}_2.filtered.fastq.gz"

(bbduk.sh ${INFQ} ${OUTFQ} ${BBOPTS}) &> ${ACC}.trim.log

echo "JOB DONE."
