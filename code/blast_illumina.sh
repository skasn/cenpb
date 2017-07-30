#!/bin/bash

#SBATCH -n 1
#SBATCH --cpus-per-task=4
#SBATCH --time=10:00:00

# BLAST illumina reads against a database

DIR=$1
DB=$2

cd ${DIR}

# At least 95% of read must match
PCT=0.5

# Number of processors
NPROC=12

# Seed for subsetting
SEED=1

NSAMPLE=1000000
if [[ ! -z $3 ]]; then
    NSAMPLE=$3
fi

BLASTOPTS="-query - -task blastn -db ${DB} -num_alignments 1 -num_threads ${NPROC}"
OUTFMT="6 qseqid qstart qend sseqid evalue sstrand pident length qlen"

# Files are of format ACCESSION_[1/2]*.fastq.gz
ACCS=(`ls *filtered.fastq.gz |\
       awk '{split($1,a,"_"); print a[1]}' | uniq`)

DBPFX=`basename ${DB}`

BDIR=blast.${DBPFX}

# Create the directory if it doesnt exist;
# if it does, delete it and start anew
if [[ ! -d ${BDIR} ]]; then
    mkdir ${BDIR}
else
    rm -rf ${BDIR}
    mkdir ${BDIR}
fi

for ACC in ${ACCS[@]}; do

    for X in {1..2}; do
        BED=${BDIR}/${ACC}_${X}.blast.bed
        FQ=${ACC}_${X}.filtered.fastq.gz
        FQS=${BDIR}/${ACC}_${X}.filtered.sample.fastq.gz

        seqtk sample -s${SEED} ${FQ} ${NSAMPLE} | gzip > ${FQS}

        # zcat ${FQS} | fastq_to_fasta_fast |\
        #  blastn ${BLASTOPTS} -outfmt "${OUTFMT}" |\
        #  awk -v T=${PCT} '{if ($6=="plus") S="+"; else S="-"; if ($8/$9 >= T)\
        #  print $1 "\t" $2-1 "\t" $3 "\t" $4 "\t" $5 "\t" S "\t" $7 "\t" $8}'\
        #  > ${BED}
        zcat ${FQS} | fastq_to_fasta_fast |\
         blastn ${BLASTOPTS} -outfmt "${OUTFMT}" |\
         blast2bed.py -i - > ${BED}

    done

done
