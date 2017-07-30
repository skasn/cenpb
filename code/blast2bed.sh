#!/bin/bash

# Provided a BLAST database and a min and max len
# return a BED formatted list of BLAST database matches; output is to
# stdout

#Usage
#get_blast_matches.sh [fasta] [blast db] [min len] [max len] [opt: nmatches] [opt: algorithm]

FA=$1
BDB=$2
MINL=$3
MAXL=$4
NMATCH=1
ALGO=dc-megablast

FAEXT="${FA##*.}"

if [[ ${FAEXT} == "gz" ]]; then
    SEQ="zcat ${FA}"
else
    SEQ="cat ${FA}"
fi

if [[ ! -z $5 ]]; then
    NMATCH=$5
fi

if [[ ! -z $6 ]]; then
    ALGO=$6
fi


OUTFMT="6 qseqid qstart qend sseqid evalue sstrand pident length"
BLASTOPTS="-task ${ALGO} -db ${BDB} -num_alignments ${NMATCH}"
${SEQ} | blastn ${BLASTOPTS} -outfmt "${OUTFMT}" -query - |\
    awk -v A=${MINL} -v B=${MAXL} \
    '{if ($6=="plus") S="+"; else S="-"; if ($8>=A && $8<=B) \
      print $1 "\t" $2-1 "\t" $3 "\t" $4 "\t" $5 "\t" S "\t" $7 "\t" $8}'
