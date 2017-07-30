#!/bin/bash

#SBATCH -n 1
#SBATCH --cpus-per-task=2
#SBATCH --time=10:00:00
#SBATCH --qos=highio

# Quality filter paired reads

URLFN=$1

# Minimum quality
MINQ=10   # Minimum quality (for trimming)
MAQ=15    # Minimum average quality
MINL=85   # Minimum length
NPROC=2   # Number of threads

if [ ! -z $2 ]; then
    MINL=$2
fi

BBOPTS="t=${NPROC} ftm=5 qtrim=rl trimq=${MINQ} maq=${MAQ} minlen=${MINL} ref=${ADAPT}"
ASPOPTS="-i ${ASPO} -Tr -Q -l 100M -L- era-fasp@fasp.sra.ebi.ac.uk:"

while read LN; do
    # Download
    FTPSTEM=`echo ${LN} | awk '{split($2,a,"uk"); print a[2]}'`
    FTPSTEM=${FTPSTEM%_*}

    ACC=`basename ${FTPSTEM}`

    ascp ${ASPOPTS}${FTPSTEM} ./

    R1=${ACC}

    bbduk_single.sh ${R1} ${MINL}

    # Clean up
    rm ${R1}

done < ${URLFN}

echo "JOB DONE."
