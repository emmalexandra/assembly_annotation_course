#!/usr/bin/env bash

#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=02:00:00
#SBATCH --job-name=quast_no_ref
#SBATCH --mail-user=emma.jakobsson@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/ejakobsson/assembly_annotation_course/logs/output_quast_no_ref_%j.o
#SBATCH --error=/data/users/ejakobsson/assembly_annotation_course/logs/error_quast_no_ref_%j.e
#SBATCH --partition=pshort_el8

WORKDIR=/data/users/ejakobsson/assembly_annotation_course
REF=/data/courses/assembly-annotation-course/references
OUTDIR=$WORKDIR/evaluation/quast_no_ref

mkdir -p $OUTDIR

apptainer exec \
--bind /data \
/containers/apptainer/quast_5.2.0.sif \
quast.py \
$WORKDIR/assemblies/flye/assembly.fasta \
$WORKDIR/assemblies/hifiasm/Db-1.bp.p_ctg.fa \
-o $OUTDIR \
--threads 8 \
--labels flye,hifiasm \
--eukaryote \
--est-ref-size 130999040 \
--large