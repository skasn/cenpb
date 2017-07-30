#!/bin/bash

# Sample negative control regions from a specified genome

GENOME=$1
INCLUDE=$2
WINSIZE=$3

SISTDIR=~/scratch/sist_codes

PFX=`basename ${GENOME%.*}`

if [ ! -d ${SISTDIR}/${PFX}.positive ]; then
    mkdir ${SISTDIR}/${PFX}.positive
fi

SISTDIR=${SISTDIR}/${PFX}.positive

# index the genome
SIZES=${GENOME%.*}.sizes
samtools faidx ${GENOME}
awk '{print $1 "\t" $2}' ${GENOME}.fai > ${SIZES}

# Compute the midpoints
MBED=${INCLUDE%.*}.mid.bed
awk '{M=int(($2+$3)/2); print $1 "\t" M "\t" M+1}'\
 ${INCLUDE} > ${MBED}

# Perform the windowing
SBED=${INCLUDE%.*}.win.${WINSIZE}.bed
bedtools slop -b ${WINSIZE} -i ${MBED} -g ${SIZES} |\
    awk '{print $1 "\t" $2 "\t" $3 "\t" $1 "_" $2 "_" $3}' > ${SBED}

# Get the FASTA file
CFA=${SBED%.*}.fa
fastaFromBed -name -fi ${GENOME} -fo - -bed ${SBED} > ${CFA}

samtools faidx ${CFA}

# Loop through and separate out sequences
ACCS=(`awk '{print $1}' ${CFA}.fai`)

for ACC in ${ACCS[@]}; do
    AFA=${SISTDIR}/${ACC}.fa
    samtools faidx ${CFA} ${ACC} > ${AFA}
done

echo "JOB DONE."
