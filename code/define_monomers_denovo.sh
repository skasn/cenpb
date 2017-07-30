#!/bin/bash

#SBATCH -n 1
#SBATCH --cpus-per-task=4
#SBATCH --time=10:00:00

# Define monomeric units based on TRF; set
# the register based on match to the DFAM/
# Repbase consensus sequence

# NOTE: BLAST database with the consensus sequence
# should be specified in the external var ALRDB

TRFDIR=$1

# Minimum and maximum tolerable
# repeat lengths
MINL=$2
MAXL=$3

# Threshold for clustering monomers
CTHRESH=0.8

# Number of processors
NPROC=4

# Min clust size (fraction of total)
CSIZE=0.01

# Default analysis name is TRF;
# alternatively can provide analysis name
NAME=trf.denovo
if [[ ! -z $4 ]]; then
    NAME=$4
fi

cd ${TRFDIR}

echo "Getting repeats in length range ${MINL}-${MAXL}."

INITFA=${NAME}.${MINL}-${MAXL}.fasta
zgrep -v "@" *.trf.gz | awk -v  A=${MINL} -v B=${MAXL} \
 '{if ($3>=A && $3<=B) print ">" NR "\n" $14}' |\
 fastx_collapser > ${INITFA}

# Get sequences of the proper length
LFILT=${INITFA%.*}.temp
samtools faidx ${INITFA}
awk -v A=${MINL} -v B=${MAXL} '{if($2>=A && $2<=B) print $1}'\
 ${INITFA}.fai > ${INITFA%.*}.acc

seqtk subseq ${INITFA} ${INITFA%.*}.acc > ${LFILT}

# Run DUST filter to get rid of junk
POPTS="-lc_method dust -lc_threshold 7 -fasta ${LFILT}"
OOPTS="-out_good ${INITFA%.*} -out_bad null"
prinseq-lite.pl ${POPTS} ${OOPTS}
rm ${LFILT}

# Run CD-HIT-EST
COUT=${INITFA%.*}.c${CTHRESH}
COPTS="-o ${COUT} -c ${CTHRESH} -bak 1 -M 0 -T ${NPROC} -d 0 -n 4 -G 0 -A 43"
(cdhit-est -i ${INITFA} ${COPTS}) &> ${COUT}.log

# Parse the BAK file
CLIST=${COUT}.lst
clust_size.py -i ${COUT}.bak.clstr > ${CLIST}

# Get names of references for clusters that are sufficiently large
TOT=`awk '{S+=$3}END{print S}' ${CLIST}`
TOPCLUST=${COUT}.top
awk -v C=${CSIZE} -v T=${TOT} '{if($3/T>=C) print $2}'\
 ${CLIST} > ${TOPCLUST}

# Get cluster sequences and reorient based on matches to
# a set of reference alphoid sequences
TTEMP=${COUT}.top.temp
TBLAST=${COUT}.top.blast
seqtk subseq ${INITFA} ${TOPCLUST} > ${TTEMP}
TFA=${TOPCLUST}.fasta
BLASTOPTS="-query ${TTEMP} -task blastn -db ${ALRDB} -num_alignments 1"
OUTFMT="6 qseqid sstrand"

blastn ${BLASTOPTS} -outfmt "${OUTFMT}" > ${TBLAST}
grep "plus" ${TBLAST} | awk '{print $1}' | sort | uniq |\
 seqtk subseq ${TTEMP} - > ${TFA}

grep "minus" ${TBLAST} | awk '{print $1}' | sort | uniq |\
 seqtk subseq ${TTEMP} - | seqtk seq -r - >> ${TFA}

rm ${TTEMP}
rm ${TBLAST}


# Create a BLAST database
(make_blastdb.sh ${TFA}) &> /dev/null

echo "JOB DONE."
