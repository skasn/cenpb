#!/bin/bash

# Convert HMM domtblout to BED (transposition of columns)
# I believe hmmsearch spits out 1-indexed, end-inclusive
# intervals; so I try to account for this. If this is
# wrong, it should not effect results substantially

# OUTPUT bed format (to stdout)
# seqid ali-st ali-end accession_name   evalue  strand score readlen

HMMOUT=$1
STRAND="+"
MINL=0
MAXL=10000000

if [[ ! -z $2 ]]; then
    STRAND=$2
fi

if [[ ! -z $3 ]]; then
    MINL=$3
fi

if [[ ! -z $3 ]]; then
    MAXL=$3
fi

grep -v "#" ${HMMOUT} | awk -v ST=${STRAND} -v A=${MINL}\
    -v B=${MAXL} '{L=$19-$18+1; if (L>=A && L<=B)   \
        print $1 "\t" $18-1 "\t" $19 "\t" $5 "_" $4 \
        "\t" $13 "\t" ST "\t" $14 "\t" $3}'
