#!/usr/bin/env bash

#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=1-00:00:00
#SBATCH --job-name=flye
#SBATCH --mail-user=emma.jakobsson@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/ejakobsson/assembly_annotation_course/logs/output_flye_%j.o
#SBATCH --error=/data/users/ejakobsson/assembly_annotation_course/logs/error_flye_%j.e
#SBATCH --partition=pibu_el8

WORKDIR=/data/users/ejakobsson/assembly_annotation_course
OUTDIR=$WORKDIR/assemblies/flye

mkdir -p $OUTDIR

apptainer exec \
--bind /data \
/containers/apptainer/flye_2.9.5.sif \
flye --pacbio-hifi $WORKDIR/Db-1/*.fastq.gz \
--out-dir $OUTDIR \
--threads 16