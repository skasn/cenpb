#!/bin/bash

# Convert file in standard BED format (where strand is supplied
# in sixth column) and FASTA into subsetted FASTA

# assumes that seqtk is in path

BED=$1
FA=$2
OUT=$3

awk '{if ($6 == "+") print}' ${BED} |\
    seqtk subseq ${FA} - > ${OUT}

awk '{if ($6 == "-") print}' ${BED} |\
    seqtk subseq ${FA} - | seqtk seq -r - >> ${OUT}
