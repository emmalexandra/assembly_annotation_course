#!/usr/bin/env bash

#SBATCH --cpus-per-task=16
#SBATCH --mem=96G
#SBATCH --time=1-00:00:00
#SBATCH --job-name=lja
#SBATCH --mail-user=emma.jakobsson@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/ejakobsson/assembly_annotation_course/logs/output_lja2_%j.o
#SBATCH --error=/data/users/ejakobsson/assembly_annotation_course/logs/error_lja2_%j.e
#SBATCH --partition=pibu_el8

WORKDIR=/data/users/ejakobsson/assembly_annotation_course
OUTDIR=$WORKDIR/assemblies/lja2

mkdir -p $OUTDIR

# Nb: 
    # Script needs to adjusted if used for more than one file.
    # --diploid option off (very low heterozygosity/inbred)
apptainer exec \
--bind /data \
/containers/apptainer/lja-0.2.sif \
lja -t 16 -o $OUTDIR/Db-1 --reads $WORKDIR/Db-1/*.fastq.gz