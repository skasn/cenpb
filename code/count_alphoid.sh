#!/bin/bash

# Parse the BLAST bed files in a directory to get
# an estimate of the number of alphoid reads

DDIR=$1
PFX=$2

COUNT=0
for F in ${DDIR}/*blast.bed; do
    FCOUNT=`awk '{print $1}' ${F} | sort | uniq | wc -l`
    COUNT=$((COUNT+FCOUNT))
done

RCOUNT=0
for F in ${DDIR}/*.fastq.gz; do
    FCOUNT=`echo $(zcat ${F} | wc -l)/4 | bc`
    RCOUNT=$((RCOUNT+FCOUNT))
done

RATIO=`echo - | awk -v A=${COUNT} -v B=${RCOUNT} '{print A/B}'`

echo "${PFX} ${COUNT} ${RCOUNT} ${RATIO}"
