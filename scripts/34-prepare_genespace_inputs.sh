#!/bin/bash

#SBATCH --job-name=genespace_inputs
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=00:30:00
#SBATCH --mail-user=emma.jakobsson@students.unibe.ch
#SBATCH --mail-type=fail,end
#SBATCH --output=/data/users/ejakobsson/logs/assembly_annotation_course/output_gs_inputs_%j.o
#SBATCH --error=/data/users/ejakobsson/logs/assembly_annotation_course/error_gs_inputs_%j.e
#SBATCH --account=class-sbl-30004-ws-2026
#SBATCH --reservation=class-sbl-30004-2026-11-04

set -euo pipefail

WORKDIR=/data/users/ejakobsson/assembly_annotation_course
COURSEDIR=/data/courses/genome_annotation_resources/2026

Accession=Db_1                       # for accession: Db-1
OTHERS=(Are_6 Est_0 Kar_1)           # three other accessions from Lian et al.

FINALDIR="$WORKDIR/output/MAKER/final"
GENES="$FINALDIR/filtered.genes.renamed.gff3"
LONGEST_PROTEINS="$FINALDIR/assembly.all.maker.proteins.fasta.renamed.longest.fasta"
OUTDIR="$WORKDIR/output/comparisons"
GENESPACE_DIR="$OUTDIR/GENESPACE"
LIAN="$COURSEDIR/data/Lian_et_al/GENESPACE"

mkdir -p "$GENESPACE_DIR/bed" "$GENESPACE_DIR/peptide" "$GENESPACE_DIR/tmp"

# my accession: BED (0-based start) from the gene lines of the filtered GFF3
awk -F'\t' 'BEGIN{OFS="\t"} $3=="gene" {
      split($9, a, ";"); split(a[1], b, "="); print $1, $4-1, $5, b[2] }' \
  "$GENES" > "$GENESPACE_DIR/bed/${Accession}.bed"

# my accession: longest-isoform proteins, IDs = gene IDs
sed '/^>/s/ .*//' "$LONGEST_PROTEINS" | sed '/^>/s/-R[A-Z]*$//' \
  > "$GENESPACE_DIR/peptide/${Accession}.fa"

# TAIR10 reference
cp "$COURSEDIR/data/TAIR10.bed" "$GENESPACE_DIR/bed/TAIR10.bed"
cp "$COURSEDIR/data/TAIR10.fa"  "$GENESPACE_DIR/peptide/TAIR10.fa"

# Three other accessions to compare with
for other in "${OTHERS[@]}"; do
  cp "$LIAN/bed/${other}.bed"    "$GENESPACE_DIR/bed/${other}.bed"
  cp "$LIAN/peptide/${other}.fa" "$GENESPACE_DIR/peptide/${other}.fa"
done

# Validate that BED and FASTA IDs match for every accession
echo -e "accession\tbed_genes\tfasta_seqs\tdup_bed\tdup_fasta\tmissing_in_fasta\textra_in_fasta"
for acc in "$Accession" TAIR10 "${OTHERS[@]}"; do
  cut -f4 "$GENESPACE_DIR/bed/${acc}.bed" | sort > "$GENESPACE_DIR/tmp/${acc}.bed.ids"
  awk '/^>/{print substr($1,2)}' "$GENESPACE_DIR/peptide/${acc}.fa" | sort > "$GENESPACE_DIR/tmp/${acc}.fa.ids"

  nbed=$(wc -l < "$GENESPACE_DIR/tmp/${acc}.bed.ids")
  nfa=$(wc -l < "$GENESPACE_DIR/tmp/${acc}.fa.ids")
  dbed=$(uniq -d "$GENESPACE_DIR/tmp/${acc}.bed.ids" | wc -l)
  dfa=$(uniq -d "$GENESPACE_DIR/tmp/${acc}.fa.ids" | wc -l)
  miss=$(comm -23 <(sort -u "$GENESPACE_DIR/tmp/${acc}.bed.ids") <(sort -u "$GENESPACE_DIR/tmp/${acc}.fa.ids") | wc -l)
  extra=$(comm -13 <(sort -u "$GENESPACE_DIR/tmp/${acc}.bed.ids") <(sort -u "$GENESPACE_DIR/tmp/${acc}.fa.ids") | wc -l)

  echo -e "${acc}\t${nbed}\t${nfa}\t${dbed}\t${dfa}\t${miss}\t${extra}"
done

echo "Input files:"
ls -l "$GENESPACE_DIR/bed" "$GENESPACE_DIR/peptide"