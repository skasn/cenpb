#!/bin/bash

# FASTX toolkit, BEDtools, and CD-HIT-EST are assumed to be in
# path

SCRIPTS=/home/skasinat/scratch/cen_structure/scripts

# Vienna RNAfold executables:
RNAFOLD=/home/skasinat/scratch/ViennaRNA-2.3.5/src/bin

# Tandem Repeats Finder (TRF) executable:
TRF=/home/skasinat/

# BBDUK
BBDUK=/home/skasinat/scratch/bbmap

# PRICE
PRICE=/home/skasinat/scratch/PriceSource140408

# PRINSEQ
PRINSEQ=/home/skasinat/scratch/prinseq-lite-0.20.4

# BEDOPS
BEDOPS=/home/skasinat/scratch/bedops

export PATH=${PATH}:${SCRIPTS}:${RNAFOLD}:${TRF}:${BBDUK}:${PRICE}:${PRINSEQ}:${BEDOPS}

# Parameters file from Vienna RNAfold for DNA
export DNAPARAMS=/home/skasinat/scratch/ViennaRNA-2.3.5/misc/dna_mathews2004.par
export TOPDIR=/home/skasinat/scratch/cen_structure

# Adapter sequences
export ADAPT=${SCRIPTS}/adapters.fa

# BLAST database
export ALRDB=${SCRIPTS}/blastdb/all

# Aspera config
export ASPO=/app/aspera-connect/3.5.1/etc/asperaweb_id_dsa.openssh

module load bowtie2
module load ncbi-blast
module load aspera-connect

#MFOLD=
