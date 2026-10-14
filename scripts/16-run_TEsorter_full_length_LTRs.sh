#!/bin/bash
#SBATCH --job-name=TEsorter_intact_LTR
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=8GB
#SBATCH --time=01:00:00
#SBATCH --mail-user=emma.jakobsson@students.unibe.ch
#SBATCH --mail-type=fail,end
#SBATCH --output=/data/users/ejakobsson/logs/assembly_annotation_course/output_TEsorter_%j.o
#SBATCH --error=/data/users/ejakobsson/logs/assembly_annotation_course/error_TEsorter_%j.e
#SBATCH --account=class-sbl-30004-ws-2026
#SBATCH --reservation=class-sbl-30004-2026-10-14

# Tool to classify TEs based on their protein domains.
# Use its REXdb plant database to assign Copia and Gypsy retrotransposons to evolutionary clades.

set -euo pipefail
COURSEDIR=/data/courses/genome_annotation_resources/2026
WORKDIR=/data/users/ejakobsson/assembly_annotation_course

# Use the intact-element FASTA
# Edit these two input paths to match your assembly's filename.
RAW="$WORKDIR/output/EDTA"
shopt -s nullglob
FASTA=("$RAW"/assembly.fasta.mod.EDTA.raw/LTR/assembly.fasta.mod.LTR.intact.raw.fa)
GFF=("$RAW"/assembly.fasta.mod.EDTA.raw/LTR/assembly.fasta.mod.LTR.intact.raw.gff3)

OUTDIR="$WORKDIR/output/LTR_full_length"
unset SINGULARITY_BIND APPTAINER_BIND SINGULARITY_TMPDIR
mkdir -p "$OUTDIR/tmp"

# Work with copies so ongoing EDTA files are not changed.
cp "${FASTA[0]}" "$OUTDIR/intact_LTR.fa"
cp "${GFF[0]}" "$OUTDIR/intact_LTR.gff3"
cd "$OUTDIR"
apptainer exec -C --bind "$WORKDIR" --bind "$COURSEDIR" \
    --bind "$OUTDIR/tmp":/tmp --pwd "$OUTDIR" \
    "$COURSEDIR/containers/TEsorter_1.3.0.sif" \
    TEsorter intact_LTR.fa -db rexdb-plant -p "$SLURM_CPUS_PER_TASK"

# After this, run script 17 to generate plots