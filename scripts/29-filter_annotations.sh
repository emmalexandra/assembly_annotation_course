#!/bin/bash
#SBATCH --job-name=filter_annotation
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH --time=01:00:00
#SBATCH --mail-user=emma.jakobsson@students.unibe.ch
#SBATCH --mail-type=fail,end
#SBATCH --output=/data/users/ejakobsson/logs/assembly_annotation_course/output_filter_%j.o
#SBATCH --error=/data/users/ejakobsson/logs/assembly_annotation_course/error_filter_%j.e
#SBATCH --account=class-sbl-30004-ws-2026
#SBATCH --reservation=class-sbl-30004-2026-10-28

set -euo pipefail

# Paths
WORKDIR=/data/users/ejakobsson/assembly_annotation_course
COURSEDIR=/data/courses/genome_annotation_resources/2026
OUTDIR="$WORKDIR/output/MAKER"
FINALDIR="$OUTDIR/final"
MAKER_SIF="$COURSEDIR/containers/MAKER_3.01.03.sif"
ANALYSIS_SIF="$COURSEDIR/containers/Annotation_analysis_R4.4.sif"

protein="assembly.all.maker.proteins.fasta"
transcript="assembly.all.maker.transcripts.fasta"
gff="assembly.all.maker.noseq.gff"

cd "$FINALDIR"

# Check that the previous steps produced their files
for f in "${gff}.renamed.gff" "${protein}.renamed.fasta" "${transcript}.renamed.fasta" output.iprscan; do
  if [ ! -s "$f" ]; then
    echo "ERROR: missing or empty: $FINALDIR/$f" >&2
    exit 1
  fi
done

run_maker_tool() {
  apptainer exec --cleanenv --env TMPDIR=/tmp \
    --bind "$OUTDIR/tmp":/tmp \
    --bind "$COURSEDIR" \
    --bind "$WORKDIR" \
    --pwd "$FINALDIR" "$MAKER_SIF" \
    "$@"
}

run_analysis_tool() {
  apptainer exec --cleanenv \
    --bind "$COURSEDIR" \
    --bind "$WORKDIR" \
    --pwd "$FINALDIR" "$ANALYSIS_SIF" \
    "$@"
}

# 3) Add InterProScan results to the GFF
run_maker_tool ipr_update_gff "${gff}.renamed.gff" output.iprscan \
  > "${gff}.renamed.iprscan.gff"

# 4) AED cumulative distribution (on the renamed GFF)
run_maker_tool perl /usr/local/bin/AED_cdf_generator.pl -b 0.025 "${gff}.renamed.gff" \
  > assembly.all.maker.renamed.gff.AED.txt

# 5) Quality filter: keep transcripts with AED < 1 and/or a Pfam domain
run_maker_tool perl /usr/local/bin/quality_filter.pl -s "${gff}.renamed.iprscan.gff" \
  > "${gff}_iprscan_quality_filtered.gff"

# 6) Keep only gene features and their subfeatures
grep -P "\tgene\t|\tCDS\t|\texon\t|\tfive_prime_UTR\t|\tthree_prime_UTR\t|\tmRNA\t" \
  "${gff}_iprscan_quality_filtered.gff" > filtered.genes.renamed.gff3
sed -i '1i##gff-version 3' filtered.genes.renamed.gff3

echo "Feature types kept:"
cut -f3 filtered.genes.renamed.gff3 | grep -v '^#' | sort | uniq -c

# 7) List the remaining mRNA IDs and filter the FASTA files
grep -P "\tmRNA\t" filtered.genes.renamed.gff3 | cut -f9 | cut -d ';' -f1 | sed 's/ID=//g' > list.txt

run_analysis_tool seqkit grep -f list.txt "${transcript}.renamed.fasta" \
  -o "${transcript}.renamed.filtered.fasta"
run_analysis_tool seqkit grep -f list.txt "${protein}.renamed.fasta" \
  -o "${protein}.renamed.filtered.fasta"

echo "mRNAs kept: $(wc -l < list.txt)"
echo "Proteins:    $(grep -c '>' "${protein}.renamed.filtered.fasta")"
echo "Transcripts: $(grep -c '>' "${transcript}.renamed.filtered.fasta")"