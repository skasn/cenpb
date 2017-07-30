#!/bin/bash

#SBATCH -n 1
#SBATCH --cpus-per-task=4
#SBATCH --time=24:00:00

# Use PRICE to assemble monomeric sequences
# similar to Melters, et al.; assumes that PRICE
# is in path

# Spoke with Daniel Melters on 6/1/17; he
# said that both the reads and seed sequences
# were randomly sampled

# Input is a pair of gzipped FASTQs

FQ1=$1
FQ2=$2

# Num threads
NPROC=4

# Number of seeds and reads
# to randomly sample
NSEEDS=50000
NREADS=500000

# Seeds for SEQTK
SEED1=0
SEED2=1

FLEN=400  # Fragment length
IDTY=95   # Percent identity required for aln to contig
NCY=10    # Number of PRICE cycles

PFX=`basename ${FQ1%_*}`

# Get seeds; modify seed1 so that the other
# end of the reads from FQ1 aren't sampled from FQ2
SEEDFA=${PFX}.assemble.seeds.fa
HS=$((NSEEDS/2))
seqtk sample -s${SEED1} ${FQ1} ${HS} |\
    fastq_to_fasta_fast > ${SEEDFA}
seqtk sample -s$((SEED1+1)) ${FQ2} ${HS} |\
    fastq_to_fasta_fast >> ${SEEDFA}

# Get sample for assembly
SFQ1=${PFX}_1.assemble.sample.fastq
SFQ2=${PFX}_2.assemble.sample.fastq

seqtk sample -s${SEED2} ${FQ1} ${NREADS} > ${SFQ1}
seqtk sample -s${SEED2} ${FQ2} ${NREADS} > ${SFQ2}

# Assemble
OUTFN=${PFX}.assemble.s1.${SEED1}.s2.${SEED2}.fasta
FPP="-fpp ${SFQ1} ${SFQ2} ${FLEN} ${IDTY}"
ICF="-icf ${SEEDFA} 1 1 5"
POPTS="-nc ${NCY} -target 90 2 1 1 -mpi 80 -o ${OUTFN} -a ${NPROC}"

(PriceTI ${FPP} ${ICF} ${POPTS}) &> ${OUTFN%.*}.log

# Clean up
rm ${SFQ2}
rm ${SFQ1}
rm ${SEEDFA}

echo "JOB DONE."
