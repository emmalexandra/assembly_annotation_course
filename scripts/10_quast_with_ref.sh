#!/usr/bin/env bash

#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=02:00:00
#SBATCH --job-name=quast
#SBATCH --mail-user=emma.jakobsson@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/ejakobsson/assembly_annotation_course/logs/output_quast_%j.o
#SBATCH --error=/data/users/ejakobsson/assembly_annotation_course/logs/error_quast_%j.e
#SBATCH --partition=pshort_el8

WORKDIR=/data/users/ejakobsson/assembly_annotation_course
REF=/data/courses/assembly-annotation-course/references
OUTDIR=$WORKDIR/evaluation/quast_with_ref

mkdir -p $OUTDIR

apptainer exec \
--bind /data \
/containers/apptainer/quast_5.2.0.sif \
quast.py \
$WORKDIR/assemblies/flye/assembly.fasta \
$WORKDIR/assemblies/hifiasm/Db-1.bp.p_ctg.fa \
-r $REF/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa \
--features $REF/Arabidopsis_thaliana.TAIR10.57.gff3 \
-o $OUTDIR \
--threads 8 \
--labels flye,hifiasm \
--eukaryote \
--large