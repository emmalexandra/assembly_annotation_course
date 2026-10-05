#!/usr/bin/env bash

#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=02:00:00
#SBATCH --job-name=nucmer
#SBATCH --mail-user=emma.jakobsson@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/ejakobsson/assembly_annotation_course/logs/output_nucmer_%j.o
#SBATCH --error=/data/users/ejakobsson/assembly_annotation_course/logs/error_nucmer_%j.e
#SBATCH --partition=pshort_el8

WORKDIR=/data/users/ejakobsson/assembly_annotation_course
OUTDIR=$WORKDIR/comparison/nucmer
CONTAINER=/containers/apptainer/mummer4_gnuplot.sif

FLYE=$WORKDIR/assemblies/flye/assembly.fasta
HIFIASM=$WORKDIR/assemblies/hifiasm/Db-1.bp.p_ctg.fa

mkdir -p $OUTDIR
cd $OUTDIR

# flye vs hifiasm
apptainer exec --bind /data $CONTAINER \
nucmer --prefix=flye_vs_hifiasm \
--breaklen 1000 \
--mincluster 1000 \
$FLYE $HIFIASM

apptainer exec --bind /data $CONTAINER \
mummerplot --prefix=flye_vs_hifiasm \
-R $FLYE -Q $HIFIASM \
--filter \
--layout \
--fat \
-t png \
--large \
flye_vs_hifiasm.delta