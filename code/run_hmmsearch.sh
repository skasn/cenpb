#!/bin/bash

# Run HMMSEARCH on FASTA files (can supply pattern; can be
# gzipped)

# Assumes hmmsearch is in path; also assumes hmm2bed script
# is in path

FNS=(`ls $1`)
HMM=$2
STRAND="+"
MINL=0
MAXL=10000000
NPROC=4

if [[ ! -z $3 ]]; then
    STRAND=$3
fi

if [[ ! -z $4 ]]; then
    MINL=$4
fi

if [[ ! -z $5 ]]; then
    MAXL=$5
fi

if [[ ! -z $6 ]]; then
    NPROC=$6
fi

HMMOPTS="--noali -o /dev/null --cpu ${NPROC} -E 50 --domE 50 --domtblout"

HPFX=`basename ${HMM%.*}`

for F in ${FNS[@]}; do
    FEXT=${F##*.}

    FTYPE=${F%.*}
    FTYPE=${F##*.}

    FPFX=`basename ${F%.*}`
    HMMOUT=${FPFX}.${HPFX}.hmm.out
    BED=${FPFX}.${HPFX}.hmm.bed

    if [[ "${FEXT}" == "gz" ]]; then
        if [[ "${FTYPE}" == "fq" ]] || [[ "${FTYPE}" == "fastq" ]]; then
            zcat ${F} | fastq_to_fasta_fast |\
                hmmsearch ${HMMOPTS} ${HMMOUT} ${HMM} -
        else
            zcat ${F} | hmmsearch ${HMMOPTS} ${HMMOUT} ${HMM} -
        fi
    else
        if [[ "${FTYPE}" == "fq" ]] || [[ "${FTYPE}" == "fastq" ]]; then

            cat ${F} | fastq_to_fasta_fast |\
                hmmsearch ${HMMOPTS} ${HMMOUT} ${HMM} -
         else
            cat ${F} | hmmsearch ${HMMOPTS} ${HMMOUT} ${HMM} -
        fi
    fi

    # Process if the output file is nonempty
    if [ -s ${HMMOUT} ]; then
        hmm2bed.sh ${HMMOUT} ${STRAND} ${MINL} ${MAXL} > ${BED}
    fi

    # remove the BED file if its empty
    if [ ! -s ${BED} ]; then
        rm ${BED}
    fi

    rm ${HMMOUT}
done
