#!/bin/bash

# Run SIST on a segment of genome -- split if needed

FA=$1

WINS=5000
STEPS=2500

OUTDIR=`dirname ${FA}`

SFA=${FA%.*}.w${WINS}.s${STEPS}.fa

chop_sequence.py -f ${FA} -s ${STEPS} -w ${WINS} > ${SFA}

# Go through and split the sequences
IDX=${SFA}.fai
samtools faidx ${SFA}

ACCS=(`awk '{print $1}' ${IDX}`)

for ACC in ${ACCS[@]}; do
    PFX=`echo ${ACC} | tr ':' '_'`

    samtools faidx ${SFA} ${ACC} > ${OUTDIR}/${PFX}.fa

done


echo "JOB DONE."

