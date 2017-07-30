#!/bin/bash

FA=$1

MAXSEQ=1000

if [ -z $1 ]; then
    exit
fi

SIST_DIR=/home/skasinat/scratch/sist_codes

samtools faidx ${FA}

PFX=${FA%.*}
OUTDIR=${SIST_DIR}/${PFX}

if [ -d ${OUTDIR} ]; then
    rm -rf ${OUTDIR}
fi

mkdir ${OUTDIR}

# Sample a small number of sequences if needed
ACCS=${OUTDIR}/sample.names
awk '{if ($2>=1500) print $1}' ${FA}.fai |\
    shuf -n ${MAXSEQ} > ${ACCS}

SFA=${OUTDIR}/sample.fasta
seqtk subseq ${FA} ${ACCS} > ${SFA}

FA=${SFA}
samtools faidx ${FA}

rm ${ACCS}

ACCS=`awk '{print $1}' ${FA}.fai | awk '{print $1}'`

# Split up the provided sequences and then split each
# further if necessary
for ACC in ${ACCS[@]}; do
    NOM=`echo ${ACC} | tr '|' '_' | tr ':' '_'`
    samtools faidx ${FA} ${ACC} > ${OUTDIR}/${NOM}.fa

    SLEN=`grep -w ${ACC} ${FA}.fai | awk '{print $2}'`

    if [ ${SLEN} -gt 9999 ]; then
        sist_split.sh ${OUTDIR}/${NOM}.fa
        gzip ${OUTDIR}/${NOM}.fa
    fi

done

cd ${SIST_DIR}

for F in ${PFX}/*.fa; do
    ./master.pl -f ${F} -a M -o ${F%.*}.algM.txt
done

for F in ${PFX}/*.fa; do
    cp ${F} ${PWD}
    FF=`basename ${F}`
    ALGC=${FF%.*}.algC.txt
    ./master.pl -f ${FF} -a C -o ${ALGC}

    mv ${ALGC} ${PFX}/
    rm ${FF}
    rm one_line.${FF%%.*}
done

echo "JOB DONE."
