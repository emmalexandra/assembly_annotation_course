#!/bin/bash

#SBATCH --job-name=mergeGFF
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=32G
#SBATCH --time=01:00:00
#SBATCH --mail-user=emma.jakobsson@students.unibe.ch
#SBATCH --mail-type=fail,end
#SBATCH --output=/data/users/ejakobsson/logs/assembly_annotation_course/output_mergeGFF_%j.o
#SBATCH --error=/data/users/ejakobsson/logs/assembly_annotation_course/error_mergeGFF_%j.e
#SBATCH --account=class-sbl-30004-ws-2026
#SBATCH --reservation=class-sbl-30004-2026-10-28

set -euo pipefail

WORKDIR=/data/users/ejakobsson/assembly_annotation_course
COURSEDIR=/data/courses/genome_annotation_resources/2026
MAKER_SIF="$COURSEDIR/containers/MAKER_3.01.03.sif"
OUTDIR="$WORKDIR/output/MAKER"

mkdir -p "$OUTDIR/tmp"
cd "$OUTDIR"

# Find the master datastore index (must be exactly one)
shopt -s nullglob
INDEXES=(*.maker.output/*_master_datastore_index.log)
test "${#INDEXES[@]}" -eq 1
INDEX="${INDEXES[0]}"

run_maker_tool() {
  apptainer exec --cleanenv --env TMPDIR=/tmp \
    --bind "$OUTDIR/tmp":/tmp \
    --bind "$COURSEDIR" \
    --bind "$WORKDIR" \
    --pwd "$OUTDIR" "$MAKER_SIF" \
    "$@"
}

# GFF3 with sequence
run_maker_tool gff3_merge -d "$INDEX" -o assembly.all.maker.gff

# GFF3 without sequence
run_maker_tool gff3_merge -n -d "$INDEX" -o assembly.all.maker.noseq.gff

# FASTA files (transcripts, proteins)
run_maker_tool fasta_merge -d "$INDEX" -o assembly