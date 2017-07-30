#!/bin/bash

#SBATCH -n 1
#SBATCH --cpus-per-task=1
#SBATCH --time=24:00:00

FASTA=$1

RNAFOLD=/home/skasinat/scratch/ViennaRNA-2.3.5/src/bin
export PATH=${PATH}:${RNAFOLD}

DNAPARAMS=/home/skasinat/scratch/ViennaRNA-2.3.5/misc/dna_mathews2004.par
# DNAPARAMS=~/Dropbox/git_repos/ViennaRNA-2.3.4/misc/dna_mathews2004.par


OUTFN=${FASTA%.*}.rnafold.txt
# The -p option allows ensemble calculation
# FOLDPARAMS="--noconv --noPS --noGU --paramFile=${DNAPARAMS} -p -g"
# RNAfold ${FOLDPARAMS} --infile=${FASTA} > ${OUTFN}

FOLDPARAMS="--noconv --noGU --paramFile=${DNAPARAMS} -L 500 -g"
RNALfold ${FOLDPARAMS} --infile=${FASTA} > ${OUTFN}

echo "JOB DONE."
