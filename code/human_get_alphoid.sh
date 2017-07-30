#!/bin/bash

#SBATCH -n 1
#SBATCH --cpus-per-task=4
#SBATCH --time=48:00:00

# Get all reads that have matches to alphoid sequence

DDIR=$1

