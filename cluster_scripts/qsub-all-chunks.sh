#!/bin/bash

#$ -S /bin/bash
#$ -wd /home/$USER/repos/TesserTable-PDFMiner

#$ -N TesserTable-PDFMiner

#$ -l h_rt=96:00:00
#$ -l h_vmem=4G
#$ -pe smp 4

#$ -l scratch=20G

#$ -j y
#$ -o /work/$USER/$JOB_NAME-$JOB_ID.out


module load git
module load anaconda
source activate ocr-pdf
for i in {0..2}
do
    export INPUTDIR="/foo/chunk_$i"
    export OUTDIR="/foo_output/chunk_$i"
    export NSLOTS="4"
    snakemake all -j $NSLOTS -n
done

