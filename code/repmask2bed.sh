#!/bin/bash

# Convert repeat masker output to BED format

RMASK=$1

grep -v "position" ${RMASK} | grep -v "score" ${RMASK} |\
 awk '{print $5 "\t" $6 "\t" $7 "\t" $10 "\t" $1}'
