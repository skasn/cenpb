#!/bin/bash

# Generate a histogram of tandem repeat lengths
# from TRF output

DDIR=$1
PFX=$2

zgrep -v "@" *trf.gz | awk '{print $3}' |\
 sort -k1,1n | uniq -c |\
 awk '{print $2 "\t" $1}' > ${PFX}.trf.len.hist.txt
