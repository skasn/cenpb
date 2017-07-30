#!/bin/bash

#SBATCH -n 1
#SBATCH --cpus-per-task=1
#SBATCH --time=24:00:00

URLFN=$1

SPECIES=${URLFN%.*}.species.txt

awk '{print $1}' ${URLFN} | sort | uniq > ${SPECIES}

while read SPC; do
    grep -w ${SPC} ${URLFN} > ${SPC}.txt

    echo "Processing ${SPC}"

    if [ ! -d ${SPC} ]; then
        mkdir ${SPC}
    fi

    # cd ${SPC}
    # sbatch dl_filter_illumina_paired.sh ../${SPC}.txt
    # cd ../

done < ${SPECIES}

rm ${SPECIES}
