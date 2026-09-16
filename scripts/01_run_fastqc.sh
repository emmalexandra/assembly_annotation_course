#!/usr/bin/env bash

#SBATCH --cpus-per-task=1
#SBATCH --mem=40G
#SBATCH --time=01:00:00
#SBATCH --job-name=fastqc
#SBATCH --mail-user=emma.jakobsson@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/user/assembly_annotation_course/logs/output_fastqc_%j.o
#SBATCH --error=/data/users/user/assembly_annotation_course/logs/error_fastqc_%j.e
#SBATCH --partition=pibu_el8

WORKDIR=/data/users/ejakobsson/assembly_annotation_course
OUTDIR=$WORKDIR/read_QC

mkdir -p $OUTDIR

apptainer exec \
--bind /data \
/containers/apptainer/fastqc-0.12.1.sif \
fastqc \
--outdir $OUTDIR \
$WORKDIR/Db-1/*.fastq.gz