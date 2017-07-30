#!/bin/bash

# Run TRF on Trace directory; submit a bunch of jobs
# to the restart queue

DIR=$1
MINL=1
MAXL=1000

if [ ! -z $2 ]; then
    MINL=$2
fi

if [ ! -z $3 ]; then
    MAXL=$3
fi

# TRF executable; assumed to be in path
FIND_TANDEM="trf407b.linux64 - 2 7 7 80 10 50 1000 -h -ngs"

JOBOPTS="-n 1 --cpus-per-task=1 --time=2:00:00 -p restart"

cd ${DIR}

for F in *fsa_nt.gz; do
    echo ${F}
    FPFX=${F%.*}.len${MINL}-${MAXL}.gz
    TRFOUT=${FPFX}.trf.gz
    if [ ! -f "${TRFOUT}" ]; then
        sbatch ${JOBOPTS} --wrap="zcat ${F} | ${FIND_TANDEM} | gzip > ${TRFOUT}" --requeue
    fi
done


# Move the output files
# mv *.trf.gz trf/

echo "JOB DONE."
