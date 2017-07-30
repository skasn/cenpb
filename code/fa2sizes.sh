#!/bin/bash

# Get a 'sizes' file for a FASTA file
# Output is two-column tab-delim:
# chrom size

# Note -- output is to STDOUT

FA=$1
samtools faidx ${FA}

awk '{print $1 "\t" $2}' ${FA}.fai
