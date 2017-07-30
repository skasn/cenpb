#!/bin/bash

GENOME=$1
BED=$2
WIN=0

if [ ! -z $3 ]; then
    WIN=$3
fi

# SIZES=${GENOME%.*}.sizes
# samtools faidx ${GENOME}
# awk '{print $1 "\t" $2}' ${GENOME}.fai > ${SIZES}

BEDFA=`basename ${BED%.*}.fa`
if [ "${WIN}" -eq 0 ]; then
    fastaFromBed -fi ${GENOME} -bed ${BED} -fo ${BEDFA}
else
    SIZES=${GENOME}.sizes
    samtools faidx ${GENOME}

    awk '{print $1 "\t" $2}' ${GENOME}.fai > ${SIZES}

    WBED=${BEDFA%.*}.bed
    awk '{M=int(($3+$2)/2); print $1 "\t" M "\t" M+1}' ${BED} |\
      bedtools slop -b ${WIN} -g ${SIZES} -i - |\
      awk '{print $1 "\t" $2 "\t" $3 "\t" $1 "_" $2 "_" $3}' |\
      fastaFromBed -name -fi ${GENOME} -fo ${BEDFA} -bed -
fi

PALOPTS="-minpallen 5 -maxpallen 100 -gaplimit 20 -nummismatches 0 -overlap"

samtools faidx ${BEDFA}

ACCS=(`awk '{print $1}' ${BEDFA}.fai`)
for ACC in ${ACCS[@]}; do
    PALOUT=`echo "${ACC}" | tr '|' '_' | tr ':' '_' | tr '-' '_'`
    PALOUT=${PALOUT}.emboss.txt
    PALFA=${PALOUT%.emboss.txt}.fa

    samtools faidx ${BEDFA} "${ACC}" > ${PALFA}

    palindrome "${PALFA}" ${PALOPTS} -outfile ${PALOUT}
    emboss2bed.sh ${PALOUT} > ${PALOUT%.*}.bed
done

echo "JOB DONE."
