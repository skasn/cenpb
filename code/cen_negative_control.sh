#!/bin/bash

# Sample negative control regions from a specified genome

GENOME=$1
EXCLUDE=$2
EWIN=$3
WINSIZE=$4

NSAMPLES=100

SISTDIR=~/scratch/sist_codes

PFX=`basename ${GENOME%.*}`

if [ ! -d ${SISTDIR}/${PFX} ]; then
    mkdir ${SISTDIR}/${PFX}
fi

SISTDIR=${SISTDIR}/${PFX}.negative

# index the genome
SIZES=${GENOME%.*}.sizes
samtools faidx ${GENOME}
awk '{print $1 "\t" $2}' ${GENOME}.fai > ${SIZES}

# Window the exclude file
EWFN=${EXCLUDE%.*}.excl.w.${EWIN}.bed
awk '{M=int(($2+$3)/2); print $1 "\t" M "\t" M+1}'\
 ${EXCLUDE} | bedtools slop -b ${EWIN} -i - -g ${SIZES} > ${EWFN}

# Get the random intervals
RBED=${GENOME%.*}.ew.${EWIN}.n${NSAMPLES}.rand.bed
bedtools random -g ${SIZES} -n $((2*NSAMPLES)) -l ${WINSIZE} |\
    bedtools intersect -v -a - -b ${EWFN} |\
    shuf -n ${NSAMPLES} |\
    awk '{print $1 "\t" $2 "\t" $3 "\t" $1 "_" $2 "_" $3}' > ${RBED}

RFA=${RBED%.*}.fa
fastaFromBed -name -fi ${GENOME} -bed ${RBED} -fo ${RFA}

samtools faidx ${RFA}

ACCS=(`awk '{print $1}' ${RFA}.fai`)

for ACC in ${ACCS[@]}; do
    AFA=${SISTDIR}/${ACC}.fa
    samtools faidx ${RFA} ${ACC} > ${AFA}
done
