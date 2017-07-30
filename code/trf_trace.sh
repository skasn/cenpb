#!/bin/bash

#SBATCH -n 1
#SBATCH --cpus-per-task=1
#SBATCH --time=24:00:00

# Run TRF on Trace directory

DIR=$1
MINL=1
MAXL=1000

if [ ! -z $2 ]; then
    MINL=$2
fi

if [ ! -z $3 ]; then
    MAXL=$3
fi

if [ ! -d trf ]; then
    mkdir trf
fi

# TRF executable; assumed to be in path
FIND_TANDEM="trf407b.linux64 - 2 7 7 80 10 50 1000 -h -ngs"

cd ${DIR}

for F in *fsa_nt.gz; do
    FPFX=${F%.*}.len${MINL}-${MAXL}.gz
    TRFOUT=${FPFX}.trf.gz
    zcat ${F} | ${FIND_TANDEM} | gzip > ${TRFOUT}
done

# Generate a histogram of tandem repeat lengths
zgrep -h -v "@" *.trf.gz | awk '{print $3}' |\
    sort -k1,1n | uniq -c | awk '{print $2 "\t" $1}' > trf.len.hist.txt

# Move the output files
mv *.trf.gz trf/

echo "JOB DONE."
