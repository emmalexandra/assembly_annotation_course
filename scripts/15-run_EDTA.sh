#!/bin/bash
#SBATCH --job-name=EDTA_annotation
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=128GB
#SBATCH --time=4-00:00:00
#SBATCH --mail-user=emma.jakobsson@students.unibe.ch
#SBATCH --mail-type=fail,end
#SBATCH --output=/data/users/ejakobsson/logs/assembly_annotation_course/output_edta_%j.o
#SBATCH --error=/data/users/ejakobsson/logs/assembly_annotation_course/error_edta_%j.e
#SBATCH --account=class-sbl-30004-ws-2026
#SBATCH --reservation=class-sbl-30004-2026-10-21

# EDTA (Extensive de novo TE Annotator) is a pipeline designed for the annotation of both structurally intact and fragmented TEs.
# https://github.com/oushujun/EDTA#edta-usage 

# Stop on failed commands, unset variables, or failures within pipelines.
set -euo pipefail

# Copy this script to your project and submit from that directory:
COURSEDIR=/data/courses/genome_annotation_resources/2026
WORKDIR=/data/users/ejakobsson/assembly_annotation_course

# Path to asssembly
GENOME="$WORKDIR/assemblies/flye/assembly.fasta"
GENOME="$(readlink -f "$GENOME")"  # Bind the real assembly when using a symlink.

# Arabidopsis coding sequences help remove gene-derived sequences from the TE library.
CDS="$COURSEDIR/data/TAIR10_cds_20110103_representative_gene_model_updated"
EDTA_SIF="$COURSEDIR/containers/EDTA_v2.3.0_TIRLearner4.sif"
OUTDIR="$WORKDIR/output/EDTA"

# Prevent inherited container settings from changing the course environment.
unset SINGULARITY_BIND APPTAINER_BIND SINGULARITY_TMPDIR

# Keep temporary files on disk, outside the container's small temporary filesystem.
mkdir -p "$OUTDIR/tmp"
cd "$OUTDIR"

# Bind exposes host directories inside the container; --pwd sets its working directory.
# Run the shared EDTA checkout, which supports the container's TIR-Learner 4.
# --step all builds the TE library; --anno 1 also annotates the genome.
# --sensitive 1 includes RepeatModeler families; --wholeelement 1 retains complete LTR elements
apptainer exec -C \
    --bind "$WORKDIR" --bind "$COURSEDIR" \
    --bind "$(dirname "$GENOME")" --bind "$(dirname "$CDS")" \
    --bind "$OUTDIR/tmp":/tmp --pwd "$OUTDIR" "$EDTA_SIF" \
    perl "$COURSEDIR/tools/EDTA_master/EDTA.pl" \
    --genome "$GENOME" \
    --overwrite 0 \
    --species others \
    --step all \
    --sensitive 1 \
    --cds "$CDS" \
    --anno 1 \
    --wholeelement 1 \
    --overwrite 1 \
    --threads "$SLURM_CPUS_PER_TASK"
