#!/bin/bash

# Count inversions in a directory by
# looping over paired BED files

DDIR=$1

cd ${DDIR}

ACCS=(`ls *bed | awk '{split($1,a,"_"); print a[1]}' | sort | uniq`)

OUTFN=inv.count.txt

if [[ -s ${OUTFN} ]]; then
    rm ${OUTFN}
fi

for ACC in ${ACCS[@]}; do

    B1=${ACC}_1*.bed
    B2=${ACC}_2*.bed

    ATEMP=${ACC}.tmp
    RNF=${ACC}.txt

    awk '{print $1}' ${B1} | sort | uniq > ${ATEMP}
    awk '{print $1}' ${B2} | sort | uniq >> ${ATEMP}

    cat ${RNF} | sort | uniq -c |\
     awk '{if ($1==2) print $2}' ${ATEMP} > ${RNF}

    NINV=`grep -whFf ${RNF} ${ACC}_*.bed | awk '{print $1 "\t" $6}' |\
     sort -k1,1 | uniq | awk '{print $1}' | uniq -c |\
     awk '{if ($1==1) print}' | wc -l`

    echo "${ACC} ${NINV}" >> ${OUTFN}

    rm ${ATEMP}

done
