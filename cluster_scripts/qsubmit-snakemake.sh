#!/bin/bash

#$ -S /bin/bash
#$ -wd /home/$USER/repos/TesserTable-PDFMiner

#$ -N TesserTable-PDFMiner

#$ -l h_rt=96:00:00
#$ -l h_vmem=4G
#$ -pe smp 4

#$ -j y
#$ -o /work/$USER/$JOB_NAME-$JOB_ID.out


module load git
module load anaconda
source activate ocr-pdf
snakemake all -j $NSLOTS

