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

    ascp ${ASPOPTS}${FTPSTEM}_1.fastq.gz ./
    ascp ${ASPOPTS}${FTPSTEM}_2.fastq.gz ./

    R1=${ACC}_1.fastq.gz
    R2=${ACC}_2.fastq.gz

    if [ -s ${R1} ] && [ -s ${R2} ]; then
        INFQ="in1=${R1} in2=${R2}"
        OUTFQ="out1=${ACC}_1.filtered.fastq.gz out2=${ACC}_2.filtered.fastq.gz"
        (bbduk.sh ${INFQ} ${OUTFQ} ${BBOPTS}) &> ${ACC}.trim.log

        # Clean up
        rm ${R1}
        rm ${R2}
    fi
done < ${URLFN}

echo "JOB DONE."
