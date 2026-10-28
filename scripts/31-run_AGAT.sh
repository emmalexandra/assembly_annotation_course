#!/bin/bash
#SBATCH --job-name=agat_stats
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH --time=01:00:00
#SBATCH --mail-user=emma.jakobsson@students.unibe.ch
#SBATCH --mail-type=fail,end
#SBATCH --output=/data/users/ejakobsson/logs/assembly_annotation_course/output_agat_%j.o
#SBATCH --error=/data/users/ejakobsson/logs/assembly_annotation_course/error_agat_%j.e
#SBATCH --account=class-sbl-30004-ws-2026
#SBATCH --reservation=class-sbl-30004-2026-10-28

set -euo pipefail

# Paths
WORKDIR=/data/users/ejakobsson/assembly_annotation_course
COURSEDIR=/data/courses/genome_annotation_resources/2026
FINALDIR="$WORKDIR/output/MAKER/final"
AGAT_SIF="$COURSEDIR/containers/AGAT_v1.4.1.sif"
OUTDIR="$WORKDIR/output/AGAT"

mkdir -p "$OUTDIR"
cd "$OUTDIR"

# Run AGAT
apptainer exec --cleanenv \
  --bind "$COURSEDIR" \
  --bind "$WORKDIR" \
  --pwd "$OUTDIR" "$AGAT_SIF" \
  agat_sp_statistics.pl \
    --gff "$FINALDIR/filtered.genes.renamed.gff3" \
    --output "$OUTDIR/annotation.stat"