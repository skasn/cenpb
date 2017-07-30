#!/bin/bash

#SBATCH -n 1
#SBATCH --cpus-per-task=1
#SBATCH --time=24:00:00

# Given a pair of BED files and a pair of FASTQs, subsample
# a desired number of reads, properly reverse complementing
# the r2 read

FQ1=$1
FQ2=$2
B1=$3
B2=$4

NREADS=30000

if [[ ! -z $5 ]]; then
    NREADS=$5
fi

PFX=${B1%.*}

ACCF=${PFX}.accf
ACC=${PFX}.acc

NN=$((NREADS/2))

OUT1=${FQ1%.*}.sample
OUT2=${FQ2%.*}.sample.rc

MINL=90

# Get reads where both ends are in the seq of interest
awk -v ML=${MINL} '{if ($8>=ML) print $1}' ${B1} |\
 sort | uniq > ${ACC}
awk -v ML=${MINL} '{if ($8>=ML) print $1}' ${B2} |\
 sort | uniq >> ${ACC}
cat ${ACC} | sort | uniq -c |\
 awk '{if ($1==2) print $2}' > ${ACCF}

# Get a list of read that are on the plus strand
# in r1
grep -wFf ${ACCF} ${B1} | awk '{if ($6=="+") print $1}' |\
 sort | uniq | shuf -n ${NN} > ${ACC}

seqtk subseq ${FQ1} ${ACC} > ${OUT1}
seqtk subseq ${FQ2} ${ACC} | seqtk seq -r - > ${OUT2}

grep -wFf ${ACCF} ${B1} | awk '{if ($6=="-") print $1}' |\
 sort | uniq | shuf -n ${NN} > ${ACC}

seqtk subseq ${FQ1} ${ACC} | seqtk seq -r - >> ${OUT1}
seqtk subseq ${FQ2} ${ACC} >> ${OUT2}

gzip ${OUT1}
gzip ${OUT2}

# Clean up
rm ${ACC}
rm ${ACCF}

echo "JOB DONE."
