#!/usr/bin/env bash

#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=02:00:00
#SBATCH --job-name=nucmer_ref
#SBATCH --mail-user=emma.jakobsson@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/ejakobsson/assembly_annotation_course/logs/output_nucmer_ref_%j.o
#SBATCH --error=/data/users/ejakobsson/assembly_annotation_course/logs/error_nucmer_ref_%j.e
#SBATCH --partition=pshort_el8

WORKDIR=/data/users/ejakobsson/assembly_annotation_course
REF=/data/courses/assembly-annotation-course/references/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa
OUTDIR=$WORKDIR/comparison/nucmer_ref
CONTAINER=/containers/apptainer/mummer4_gnuplot.sif

mkdir -p $OUTDIR
cd $OUTDIR

declare -A ASSEMBLIES=(
  [flye]=$WORKDIR/assemblies/flye/assembly.fasta
  [hifiasm]=$WORKDIR/assemblies/hifiasm/Db-1.bp.p_ctg.fa
  # [lja]=$WORKDIR/assemblies/lja/... # add if you get a usable LJA output
)

for name in "${!ASSEMBLIES[@]}"; do
  QUERY=${ASSEMBLIES[$name]}

  apptainer exec --bind /data $CONTAINER \
  nucmer --prefix=${name}_vs_ref \
  --breaklen 1000 \
  --mincluster 1000 \
  $REF $QUERY

  apptainer exec --bind /data $CONTAINER \
  mummerplot --prefix=${name}_vs_ref \
  -R $REF -Q $QUERY \
  --filter \
  --layout \
  --fat \
  -t png \
  --large \
  ${name}_vs_ref.delta
done