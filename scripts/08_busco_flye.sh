#!/usr/bin/env bash

#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=02:00:00
#SBATCH --job-name=busco_flye
#SBATCH --mail-user=emma.jakobsson@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/ejakobsson/assembly_annotation_course/logs/output_busco_flye_%j.o
#SBATCH --error=/data/users/ejakobsson/assembly_annotation_course/logs/error_busco_flye_%j.e
#SBATCH --partition=pshort_el8

WORKDIR=/data/users/ejakobsson/assembly_annotation_course
OUTDIR=$WORKDIR/evaluation/busco

mkdir -p $OUTDIR
cd $OUTDIR

apptainer exec \
--bind /data \
/containers/apptainer/busco_5.7.1.sif \
busco -i $WORKDIR/assemblies/flye/assembly.fasta \
      -o busco_flye \
      -l brassicales_odb10 \
      --mode genome \
      --cpu 8