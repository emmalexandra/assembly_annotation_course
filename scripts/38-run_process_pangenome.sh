#!/bin/bash
#SBATCH --job-name=process_pangenome
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --time=00:30:00
#SBATCH --mail-user=emma.jakobsson@students.unibe.ch
#SBATCH --mail-type=fail,end
#SBATCH --output=/data/users/ejakobsson/logs/assembly_annotation_course/output_pangenome_%j.o
#SBATCH --error=/data/users/ejakobsson/logs/assembly_annotation_course/error_pangenome_%j.e
#SBATCH --account=class-sbl-30004-ws-2026
#SBATCH --reservation=class-sbl-30004-2026-11-11

set -euo pipefail

WORKDIR=/data/users/ejakobsson/assembly_annotation_course
COURSEDIR=/data/courses/genome_annotation_resources/2026
ANALYSIS_SIF="$COURSEDIR/containers/Annotation_analysis_R4.4.sif"

# Host-backed temporary storage for R
TMPDIR="$WORKDIR/output/comparisons/Annotation_R_tmp"
mkdir -p "$TMPDIR"

cd "$WORKDIR"

apptainer exec --cleanenv \
  --bind /data \
  --bind "$WORKDIR" \
  --bind "$TMPDIR":/temp \
  --env TMPDIR=/temp \
  --pwd "$WORKDIR" \
  "$ANALYSIS_SIF" \
  Rscript "$WORKDIR/scripts/37-process_pangenome.R"