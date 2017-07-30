#!/bin/bash

#SBATCH -n 1
#SBATCH --cpus-per-task=4
#SBATCH --time=24:00:00

DDIR=$1
HMMFN=$2

MINL=141
MAXL=201

NPROC=4

# E-value and overlap
# thresholds for parsing HMM outputs
ETHR=10
OTHR=40


cd ${DDIR}

if [ ! -d hmm ]; then
    mkdir hmm
fi

HOPTS="${MINL} ${MAXL} ${NPROC}"

for F in fasta*.gz; do

    FPFX=`basename ${F%.*}`

    FBED=${FPFX%.*}.hmm.bed

    # Run HMMER
    while read LINE; do
        HMM=`echo ${LINE} | awk '{print $1}'`
        STRAND=`echo ${LINE} | awk '{print $2}'`

        HPFX=`basename ${HMM%.*}`
        HMMBED=${FPFX}.${HPFX}.hmm.bed

        # Run HMM
        run_hmmsearch.sh ${F} ${HMM} ${STRAND} ${HOPTS}

        # Get the subsequences that match HMM
        if [ -f ${HMMBED} ] && [ ! -s ${HMMBED} ]; then
            rm ${HMMBED}
        fi

    done < ${HMMFN}


    # # If there are HMM matches, then process them
    # # by first deduplicating and then getting the
    # # corresponding FASTA sequence
    # BEDS=(`ls ${FPFX}*.bed 2>/dev/null`)

    # if [ ${#BEDS[@]} -gt 0 ]; then
    #     HPFX=`basename ${HMMFN%.*}`
    #     HMMBED=${FPFX}.${HPFX}.bed
    #     HMMFA=${FPFX}.${HPFX}.fa
    #     HMMFULLFA=${FPFX}.${HPFX}.full.fa
    #     HMMACC=${FPFX}.${HPFX}.acc

    #     # get_optimal_bed_intervals.py -b -f ${BEDS[@]} > ${HMMBED}
    #     cat ${BEDS[@]} | sort -k1,1 -k2,2n -k5,5nr > ${FPFX}.tmp

    #     resolve_hmmsearch_overlaps.py -f ${FPFX}.tmp -e ${ETHR} -o ${OTHR} > ${HMMBED}

    #     rm ${FPFX}.tmp

    #     if [ -s ${HMMBED} ]; then
    #         # Get the HMM matches
    #         stranded_bed_to_fasta.sh ${HMMBED} ${F} ${HMMFA}
    #     fi

    #     # Get the full reads that match
    #     cat ${BEDS[@]} | awk '{print $1}' | sort | uniq > ${HMMACC}
    #     seqtk subseq ${F} ${HMMACC} > ${HMMFULLFA}
    #     rm ${HMMACC}

    #     mv ${BEDS[@]} hmm/
    # fi
done


echo "JOB DONE."
