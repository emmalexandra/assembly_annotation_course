#!/bin/bash
#SBATCH --job-name=circlize
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16GB
#SBATCH --time=02:00:00
#SBATCH --mail-user=emma.jakobsson@students.unibe.ch
#SBATCH --mail-type=fail,end
#SBATCH --output=/data/users/ejakobsson/logs/assembly_annotation_course/output_circlize_%j.o
#SBATCH --error=/data/users/ejakobsson/logs/assembly_annotation_course/error_circlize_%j.e
#SBATCH --account=class-sbl-30004-ws-2026
#SBATCH --reservation=class-sbl-30004-2026-10-21

set -euo pipefail

# Set paths
WORKDIR=/data/users/ejakobsson/assembly_annotation_course
COURSEDIR=/data/courses/genome_annotation_resources/2026

SIF="$COURSEDIR/containers/Annotation_analysis_R4.4.sif"

# Input and output
ASSEMBLY="$WORKDIR/assemblies/flye/assembly.fasta"
TEANNO="$WORKDIR/output/EDTA/assembly.fasta.mod.EDTA.TEanno.gff3"
RSCRIPT="$WORKDIR/scripts/19-annotation_circlize.R"
PLOTDIR="$WORKDIR/output/circlize"

# Names must match what the R script reads
for f in "$ASSEMBLY" "$TEANNO" "$RSCRIPT" "$SIF"; do
    [[ -e "$f" ]] || { echo "ERROR: missing file: $f" >&2; exit 1; }
done

# The R script reads its inputs by relative filename, so link them into PLOTDIR
mkdir -p "$PLOTDIR"
cd "$PLOTDIR"
ln -sf "$ASSEMBLY" assembly.fasta
ln -sf "$TEANNO"   assembly.fasta.mod.EDTA.TEanno.gff3
 
# Step 1: index the assembly -> assembly.fasta.fai (scaffold lengths for the ideogram)
echo "[$(date)] samtools faidx"
apptainer exec -C --bind "$WORKDIR" --pwd "$PLOTDIR" "$SIF" \
    samtools faidx assembly.fasta
 
# Step 2: run the circlize R script -> 02-TE_density.pdf
echo "[$(date)] Rscript"
apptainer exec -C --bind "$WORKDIR" --pwd "$PLOTDIR" "$SIF" \
    Rscript "$RSCRIPT"
 
echo "[$(date)] Finished. Output: $PLOTDIR/02-TE_density.pdf"