#!/bin/bash

#SBATCH -n 1
#SBATCH --cpus-per-task=16
#SBATCH --time=24:00:00
#SBATCH -p largenode
#SBATCH --mem=100G

# AGM
DDIR=/home/skasinat/henikoff/solexa/170713_D00300_0453_BHNG2MBCXY/Unaligned/Project_henikoff
# DIRS=(${DDIR}/Sample_SH_CaSc_CeALo_0630 ${DDIR}/Sample_SH_CaSc_CeBLo_0630)
# DIRS+=(${DDIR}/Sample_SH_CaSc_CeCLo_0630 ${DDIR}/Sample_SH_CaSc_IgGLo_0630)
DIRS=()
DIRS+=(${DDIR}/Sample_SH_CaSc_K27Lo_0630)
# IDX=/home/skasinat/scratch/cen_structure/bt2/agm_alphasat_bac
# IDX=/home/skasinat/scratch/cen_structure/bt2/agm_sanger_alphoid
IDX=/home/skasinat/scratch/cen_structure/bt2/csab.masked

# Human
# DIRS=(/home/skasinat/henikoff/solexa/170510_SN367_0918_AHLJW5BCXY/Unaligned/Project_henikoff/Sample_SH_HsSc_CeBlN10m0501)
# DDIR=/home/skasinat/henikoff/solexa/170313_SN367_0882_BHHJG7BCXY/Unaligned/Project_henikoff
# DIRS+=(${DDIR}/Sample_SH_HsSc_CeAm_lo_0306)
# DIRS+=(${DDIR}/Sample_SH_HsSc_CeC_lo_0306)
# DIRS=()
# DIRS+=(${DDIR}/Sample_SH_HsSc_K27_lo_0306)
# IDX=/home/skasinat/scratch/cen_structure/bt2/human_asat.1.25kb.no_ambig
# IDX=/home/skasinat/scratch/cen_structure/bt2/bacs_6kb
# IDX=/home/skasinat/scratch/cen_structure/bt2/hg38_masked

NPROC=16
MINLEN=10
MAXLEN=700
BT2OPTS="-p ${NPROC} --end-to-end --very-sensitive --no-unal --no-mixed --no-discordant --overlap --dovetail -I ${MINLEN} -X ${MAXLEN}"

module load bowtie2

TOPDIR=/home/skasinat/scratch/cen_structure/cutnrun

for DD in ${DIRS[@]}; do

    echo ${DD}

    OUTNAME=`basename ${DD}`
    OUTNAME=${OUTNAME}.`basename ${IDX}`

    R1=`ls -m ${DD}/*R1*gz | tr -d ' ' | tr -d '\n'`
    R2=`ls -m ${DD}/*R2*gz | tr -d ' ' | tr -d '\n'`

    bowtie2 ${BT2OPTS} -x ${IDX} -1 ${R1} -2 ${R2} | \
        samtools view -bS - > ${TOPDIR}/${OUTNAME}.bam

done

echo "JOB DONE."
