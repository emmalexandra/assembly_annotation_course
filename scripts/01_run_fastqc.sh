#!/usr/bin/env bash

#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=02:00:00
#SBATCH --job-name=fastqc
#SBATCH --mail-user=emma.jakobsson@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/ejakobsson/assembly_annotation_course/logs/output_fastqc_%j.o
#SBATCH --error=/data/users/ejakobsson/assembly_annotation_course/logs/error_fastqc_%j.e
#SBATCH --partition=pshort_el8

WORKDIR=/data/users/ejakobsson/assembly_annotation_course
OUTDIR=$WORKDIR/read_QC

mkdir -p $OUTDIR

apptainer exec \
--bind /data \
/containers/apptainer/fastqc-0.12.1.sif \
fastqc \
--outdir $OUTDIR \
$WORKDIR/Db-1/*.fastq.gz \
$WORKDIR/RNAseq_Sha/*.fastq.gz