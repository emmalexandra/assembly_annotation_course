#!/bin/bash

#SBATCH --job-name=uniprot_function
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=01:00:00
#SBATCH --mail-user=emma.jakobsson@students.unibe.ch
#SBATCH --mail-type=fail,end
#SBATCH --output=/data/users/ejakobsson/logs/assembly_annotation_course/output_uniprot_function_%j.o
#SBATCH --error=/data/users/ejakobsson/logs/assembly_annotation_course/error_uniprot_function_%j.e
#SBATCH --account=class-sbl-30004-ws-2026
#SBATCH --reservation=class-sbl-30004-2026-11-04

set -euo pipefail

# Set paths
WORKDIR=/data/users/ejakobsson/assembly_annotation_course
COURSEDIR=/data/courses/genome_annotation_resources/2026
FINALDIR="$WORKDIR/output/MAKER/final"
PROTEINS="$FINALDIR/assembly.all.maker.proteins.fasta.renamed.filtered.fasta"
UNIPROT="$COURSEDIR/data/uniprot_viridiplantae_reviewed.fa"
OUTDIR="$WORKDIR/output/comparisons"
MAKER_SIF="$COURSEDIR/containers/MAKER_3.01.03.sif"
GENES="$FINALDIR/filtered.genes.renamed.gff3"

mkdir -p "$OUTDIR/tmp"
cd "$OUTDIR"

run_maker_tool() {
  apptainer exec --cleanenv --env TMPDIR=/tmp \
    --bind /data \
    --bind "$WORKDIR" \
    --bind "$OUTDIR/tmp":/tmp \
    --pwd "$OUTDIR" "$MAKER_SIF" \
    "$@"
}

# Protein FASTA with UniProt functions added to the headers
run_maker_tool maker_functional_fasta "$UNIPROT" "$OUTDIR/blastp_uniprot.besthits.tsv" "$PROTEINS" \
  > "$OUTDIR/maker_proteins.filtered.Uniprot.fasta"

# Gene GFF3 with UniProt functions added to the attributes
run_maker_tool maker_functional_gff "$UNIPROT" "$OUTDIR/blastp_uniprot.besthits.tsv" "$GENES" \
  > "$OUTDIR/filtered.genes.Uniprot.gff3"

echo "Proteins in output: $(grep -c '>' "$OUTDIR/maker_proteins.filtered.Uniprot.fasta")"
echo "Genes in output:    $(awk '$3=="gene"' "$OUTDIR/filtered.genes.Uniprot.gff3" | wc -l)"