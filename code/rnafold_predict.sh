#!/bin/bash

#SBATCH -n 1
#SBATCH --cpus-per-task=1
#SBATCH --time=48:00:00

# Run structure predicting using Vienna RNAfold

FA=$1
FOLDOUT=$2

FOLDPARAMS="--noconv --noPS --noGU --paramFile=${DNAPARAMS}"
RNAfold ${FOLDPARAMS} --infile=${FA} > ${FOLDOUT}

echo "JOB DONE."
