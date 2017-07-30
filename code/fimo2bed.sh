#!/bin/bash

# Convert fimo text output to BED

FIMO=$1

grep -v "#" ${FIMO} | awk '{print $2 "\t" $3-1 \
 "\t" $4 "\t" $1 "\t" $7 "\t" $5 "\t" $6 "\t" $8}'
