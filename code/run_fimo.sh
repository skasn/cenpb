#!/bin/bash

# Run fimo (assumed to be in path)

SEQFN=$1
MOTIF=$2

THRESH=0.001

if [ ! -z $3 ]; then
    THRESH=$3
fi

SPFX=`basename ${SEQFN%.*}`
MPFX=`basename ${MOTIF%.*}`
PFX=${SPFX}.${MPFX}.fimo

# Convert the input to fasta just in case its
# a fastq file
FA=${SPFX}.temp.fa
seqtk seq -a ${SEQFN} > ${FA}

FOPTS="--text --thresh ${THRESH}"

# Run FIMO
fimo ${FOPTS} ${MOTIF} ${FA} > ${PFX}.txt

# Clean up
rm ${FA}

echo "JOB DONE."
