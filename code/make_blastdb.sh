#!/bin/bash

# Given a FASTA file, make a blast database

FA=$1

DBNAME=`basename ${FA%.*}`

makeblastdb -in ${FA} -dbtype nucl -out ${DBNAME}

echo "JOB DONE."
