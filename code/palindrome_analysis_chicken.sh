#!/bin/bash

SPECIES=(galGal5)
GDIR=~/scratch/cen_structure/genomes
ADIR=~/scratch/cen_structure/annot

WIN=250000
EXCL=1000000

for S in ${SPECIES[@]}; do
    G=${GDIR}/${S}.fa
    BED=${ADIR}/${S}.cen.bed

    if [ -d ${S}_cen ]; then
        rm -r ${S}_cen
    fi

    mkdir ${S}_cen
    cd ${S}_cen

    # Do the positive controls
    pal.sh ${G} ${BED} ${WIN}

    cd ../

    if [ -d ${S}_random ]; then
        rm -r ${S}_random
    fi

    mkdir ${S}_random
    cd ${S}_random

    # Do the negative controls
    pal_rand.sh ${G} ${BED} ${EXCL} $((2*WIN))

    cd ../
done
