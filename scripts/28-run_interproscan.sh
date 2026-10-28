#!/bin/bash

#SBATCH --job-name=interproscan
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=02:00:00
#SBATCH --mail-user=emma.jakobsson@students.unibe.ch
#SBATCH --mail-type=fail,end
#SBATCH --output=/data/users/ejakobsson/logs/assembly_annotation_course/output_interproscan_%j.o
#SBATCH --error=/data/users/ejakobsson/logs/assembly_annotation_course/error_interproscan_%j.e
#SBATCH --account=class-sbl-30004-ws-2026
#SBATCH --reservation=class-sbl-30004-2026-10-28

set -euo pipefail

# Paths
WORKDIR=/data/users/ejakobsson/assembly_annotation_course
COURSEDIR=/data/courses/genome_annotation_resources/2026
OUTDIR="$WORKDIR/output/MAKER"
FINALDIR="$OUTDIR/final"
INTERPROSCAN_SIF="$COURSEDIR/containers/InterProScan_5.70.sif"

protein="assembly.all.maker.proteins.fasta"

mkdir -p "$FINALDIR/tmp"
cd "$FINALDIR"

# Run InterProScan
apptainer exec --cleanenv --pwd "$FINALDIR" \
  --bind "$COURSEDIR/data/interproscan-5.70-102.0/data":/opt/interproscan/data \
  --bind "$COURSEDIR" \
  --bind "$WORKDIR" \
  --bind "$FINALDIR/tmp":/temp \
  "$INTERPROSCAN_SIF" \
  /opt/interproscan/interproscan.sh \
  -appl pfam --disable-precalc -f TSV \
  --goterms --iprlookup --seqtype p \
  -cpu "$SLURM_CPUS_PER_TASK" \
  -i "${protein}.renamed.fasta" -o output.iprscan