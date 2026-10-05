#!/usr/bin/env bash

#SBATCH --cpus-per-task=8
#SBATCH --mem=32GB
#SBATCH --time=02:00:00
#SBATCH --job-name=merqury
#SBATCH --mail-user=emma.jakobsson@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/ejakobsson/assembly_annotation_course/logs/output_merqury_%j.o
#SBATCH --error=/data/users/ejakobsson/assembly_annotation_course/logs/error_merqury_%j.e
#SBATCH --partition=pshort_el8

export MERQURY="/usr/local/share/merqury"

WORKDIR=/data/users/ejakobsson/assembly_annotation_course
OUTDIR=$WORKDIR/evaluation/merqury
CONTAINER=/containers/apptainer/merqury_1.3.sif

mkdir -p $OUTDIR
cd $OUTDIR

# Build meryl db from HiFi reads (k=31)
apptainer exec --bind /data $CONTAINER \
meryl k=31 count $WORKDIR/Db-1/*.fastq.gz output $OUTDIR/Db-1.meryl

# Run merqury, comparing both genome assemblies against the reads
apptainer exec --bind /data $CONTAINER \
merqury.sh $OUTDIR/Db-1.meryl \
$WORKDIR/assemblies/flye/assembly.fasta \
$WORKDIR/assemblies/hifiasm/Db-1.bp.p_ctg.fa \
merqury_Db1