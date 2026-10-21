#!/bin/bash
#SBATCH --job-name=TEsorter_Copia_Gypsy
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16GB
#SBATCH --time=01:00:00
#SBATCH --mail-user=emma.jakobsson@students.unibe.ch
#SBATCH --mail-type=fail,end
#SBATCH --output=/data/users/ejakobsson/logs/assembly_annotation_course/output_TEsorter_Copia_Gypsy_%j.o
#SBATCH --error=/data/users/ejakobsson/logs/assembly_annotation_course/error_TEsorter_Copia_Gypsy_%j.e
#SBATCH --account=class-sbl-30004-ws-2026
#SBATCH --reservation=class-sbl-30004-2026-10-21

# Stop on failed commands, unset variables, or failures within pipelines.

set -euo pipefail

# Shared course software and your project folder
COURSEDIR=/data/courses/genome_annotation_resources/2026
WORKDIR=/data/users/ejakobsson/assembly_annotation_course

# Containers
R_SIF="$COURSEDIR/containers/Annotation_analysis_R4.4.sif" # contains seqkit
TESORTER_SIF="$COURSEDIR/containers/TEsorter_1.3.0.sif"

# Input: EDTA TE library (full-length and truncated TE sequences)
TELIB="$WORKDIR/output/EDTA/assembly.fasta.mod.EDTA.TElib.fa"

# Output folder for the extracted sequences and TEsorter results
OUTDIR="$WORKDIR/output/TEsorter_Copia_Gypsy"

# Prevent inherited container settings from changing the course environment.
unset SINGULARITY_BIND APPTAINER_BIND
mkdir -p "$OUTDIR"
cd "$OUTDIR"

#Step 1: extract Copia and Gypsy sequences from the TE library
# -r = pattern is a regular expression, -p = pattern to search in sequence IDs

apptainer exec -C --bind "$WORKDIR" "$R_SIF" \
    seqkit grep -r -p "Copia" "$TELIB" > Copia_sequences.fa
apptainer exec -C --bind "$WORKDIR" "$R_SIF" \
    seqkit grep -r -p "Gypsy" "$TELIB" > Gypsy_sequences.fa

# Step 2: classify the sequences into clades with TEsorter (REXdb plant database)

apptainer exec --bind "$WORKDIR" --pwd "$OUTDIR" "$TESORTER_SIF" \
    TEsorter Copia_sequences.fa -db rexdb-plant -p "$SLURM_CPUS_PER_TASK"
apptainer exec --bind "$WORKDIR" --pwd "$OUTDIR" "$TESORTER_SIF" \
    TEsorter Gypsy_sequences.fa -db rexdb-plant -p "$SLURM_CPUS_PER_TASK"