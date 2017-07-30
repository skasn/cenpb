#!/bin/bash

# Convert EMBOSS palindrome file to BED

PFILE=$1
PFX=emboss
if [ ! -z $2 ]; then
    PFX=$2
fi

grep -v "|" ${PFILE} | grep -v ":" | awk -v A=${PFX} \
    '{L=length($2); S=$1; E=$3; if (S>E) {E=$1-1; S=$3-1}; if (L>0) print A "\t" S "\t" E "\t" L}'
