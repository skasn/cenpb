#!/bin/bash

# Search for matches to the CENP-B box sequence in random samples
# of the genome

FQ=$1
PATTERN=$2

PFX=`basename ${PATTERN%.*}`

OUTFN=${FQ%.*}.${PFX}.counts.txt

count_regex_occurrences.py -z ${FQ} -r ${PATTERN} -o ${OUTFN}

echo "JOB DONE."
