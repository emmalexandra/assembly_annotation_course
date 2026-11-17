#!/bin/bash
#SBATCH --job-name=riparian
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=16G
#SBATCH --time=01:00:00
#SBATCH --output=/data/users/ejakobsson/logs/assembly_annotation_course/output_riparian_%j.o
#SBATCH --error=/data/users/ejakobsson/logs/assembly_annotation_course/error_riparian_%j.e
#SBATCH --account=class-sbl-30004-ws-2026
#SBATCH --reservation=class-sbl-30004-2026-11-11

set -euo pipefail

WORKDIR=/data/users/ejakobsson/assembly_annotation_course
COURSEDIR=/data/courses/genome_annotation_resources/2026
GENESPACE_SIF="$COURSEDIR/containers/genespace_latest.sif"
TMPDIR="$WORKDIR/output/comparisons/GENESPACE_R_tmp"
mkdir -p "$TMPDIR"

apptainer exec --cleanenv \
  --bind /data --bind "$WORKDIR" \
  --bind "$TMPDIR":/temp --env TMPDIR=/temp --pwd "$WORKDIR" \
  "$GENESPACE_SIF" \
  Rscript "$WORKDIR/scripts/39-riparian.R"