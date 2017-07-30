#!/bin/bash

# Create BED files for positive and negative
# control regions

BED=$1
FA=$2
WIN=$3
EXCL=$4
NRAN=100

if [ ! -z $5 ]; then
    NRAN=$5
fi

PFX=`basename ${BED%.*}`
SIZES=${FA%.*}

if [ ! -s ${SIZES} ]; then
    samtools faidx ${FA}
    awk '{print $1 "\t" $2}' ${FA}.fai > ${SIZES}
fi

# get midpoints
MBED=${PFX}.mid.bed
awk '{M=int(($2+$3)/2); print $1 "\t" M "\t" M+1}' ${BED} > ${MBED}

# Slop
SBED=${PFX}.mid.win${3}.bed
bedtools slop -b ${WIN} -i ${MBED} -g ${SIZES} > ${SBED}

# Get neg control
EBED=${SBED%.*}.additional.${EXCL}.bed
bedtools slop -b ${EXCL} -i ${SBED} -g ${SIZES} > ${EBED}

# Get randoms
RBED=${PFX}.$((WIN+EXCL)).random.bed
bedtools random -n $((10*NRAN)) -l $((WIN*2+1)) -g ${SIZES} |\
    bedtools intersect -v -wa -a - -b ${EBED} > ${RBED}

# Get the sequences
WFA=${SBED%.*}.fa
seqtk subseq ${FA} ${SBED}  > ${WFA}
RFA=${RBED%.*}.fa
seqtk subseq ${FA} ${RBED} | seqtk seq -N - |\
    seqtk sample - ${NRAN} > ${RFA}

echo "JOB DONE."
