#!/bin/bash

#SBATCH -n 1
#SBATCH --cpus-per-task=1
#SBATCH --qos=highio
#SBATCH --time=24:00:00

# Download a bunch of primate data from the NCBI Trace archive

TRACE_URL=ftp://ftp-private.ncbi.nlm.nih.gov/pub/TraceDB/
DATALIST=${TOPDIR}/trace_datasets_round2.txt

TRACEDIR=${TOPDIR}/trace

# Make a directory
if [[ ! -d ${TRACEDIR} ]]; then
    mkdir ${TRACEDIR}
fi

cd ${TRACEDIR}

while read LINE; do
    DIRNAME=`echo ${LINE} | awk '{print $1}'`
    FTPF=`echo ${LINE} | awk '{print $2}'`

    echo "Downloading ${FTPF} into ${DIRNAME}"

    DIRNAME=${TRACEDIR}/${DIRNAME}

    if [[ ! -d ${DIRNAME} ]]; then
        mkdir ${DIRNAME}
    fi

    cd ${DIRNAME}

    wget --quiet ${TRACE_URL}/${FTPF}/fasta*

    cd ${TRACEDIR}

done < ${DATALIST}

echo "JOB DONE."
