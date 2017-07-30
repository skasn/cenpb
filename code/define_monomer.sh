#!/bin/bash

#SBATCH -n 1
#SBATCH --cpus-per-task=1
#SBATCH --time=10:00:00

# Define monomeric units based on TRF; set
# the register based on match to the DFAM/
# Repbase consensus sequence

# NOTE: BLAST database with the consensus sequence
# should be specified in the external var ALRDB

TRFDIR=$1

# Minimum and maximum tolerable
# repeat lengths
MINL=$2
MAXL=$3

# Directory containing the raw FASTA sequences
# on which TRF was run
DATADIR=$4

# Threshold for clustering monomers
CTHRESH=0.8

# Default analysis name is TRF;
# alternatively can provide analysis name
NAME=trf
if [[ ! -z $5 ]]; then
    NAME=$5
fi

cd ${TRFDIR}

echo "Getting repeats in length range ${MINL}-${MAXL}."

INITFA=${NAME}.${MINL}-${MAXL}.fasta
zgrep -v "@" *.trf.gz | awk -v  A=${MINL} -v B=${MAXL} \
 '{if ($3>=A && $3<=B) print ">" NR "\n" $14}' |\
 fastx_collapser > ${INITFA}

echo "BLASTing against ${ALRDB}."

# Run BLAST to identify sequences with proper length; convert to
# BED with 0-indexed coords
BBED=${NAME}.${MINL}-${MAXL}.bed
blast2bed.sh ${INITFA} ${ALRDB} ${MINL} ${MAXL} > ${BBED}

echo "Getting in-register matches."

# Get the re-defined monomers
REDEF=${INITFA%.*}.redef.fasta
fastaFromBed -s -fi ${INITFA} -bed ${BBED} -fo ${REDEF}
# seqtk subseq ${INITFA} ${BBED} > ${REDEF}

echo "Clustering in-register matches"

# Run CD-HIT-EST to cluster the resulting monomers
COUT=${REDEF%.*}.c${CTHRESH}
COPTS="-o ${COUT} -c ${CTHRESH} -bak 1 -M 0"
(cdhit-est -i ${REDEF} ${COPTS}) &> ${COUT}.log

echo "Getting monomers."

# Get the cluster consensus sequences and re-annotate
# all of the reads

# make a BLAST database of the cluster consensus sequences
mv ${COUT} ${COUT}.consensus.fasta
COUT=${COUT}.consensus.fasta
(make_blastdb.sh ${COUT}) &> /dev/null
DBNAME=${COUT%.*}

if [[ ! -d monomers ]]; then
    mkdir monomers
fi

MONOFA=monomers/${REDEF%.*}.inreg.fa

if [[ -s ${MONOFA} ]]; then
    rm ${MONOFA}
fi

for FA in `ls ${DATADIR}/*.gz`; do
    echo " ${FA}"
    FBED=monomers/`basename ${FA%.*}`.bed
    blast2bed.sh ${FA} ${DBNAME} ${MINL} ${MAXL} > ${FBED}

    grep -w \+ ${FBED} | seqtk subseq ${FA} - >> ${MONOFA}
    grep -w \- ${FBED} | seqtk subseq ${FA} - |\
     seqtk seq -r - >> ${MONOFA}

done

echo "JOB DONE."
