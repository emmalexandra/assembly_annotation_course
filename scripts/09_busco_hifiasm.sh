#!/usr/bin/env bash

#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=02:00:00
#SBATCH --job-name=busco_hifiasm
#SBATCH --mail-user=emma.jakobsson@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/ejakobsson/assembly_annotation_course/logs/output_busco_hifiasm_%j.o
#SBATCH --error=/data/users/ejakobsson/assembly_annotation_course/logs/error_busco_hifiasm_%j.e
#SBATCH --partition=pshort_el8

WORKDIR=/data/users/ejakobsson/assembly_annotation_course
OUTDIR=$WORKDIR/evaluation/busco

mkdir -p $OUTDIR
cd $OUTDIR

# Nb: adapt path to assembly and mode (genome or transcriptome)
apptainer exec \
--bind /data \
/containers/apptainer/busco_5.7.1.sif \
busco -i $WORKDIR/assemblies/hifiasm/Db-1.bp.p_ctg.fa \
      -o busco_hifiasm \
      -l brassicales_odb10 \
      --mode genome \
      --cpu 8