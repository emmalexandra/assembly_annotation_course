#!/bin/bash
#SBATCH --job-name=TE_plot_dating
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=16GB
#SBATCH --time=00:30:00
#SBATCH --mail-user=emma.jakobsson@students.unibe.ch
#SBATCH --mail-type=fail,end
#SBATCH --output=/data/users/ejakobsson/logs/assembly_annotation_course/output_TEplot_%j.o
#SBATCH --error=/data/users/ejakobsson/logs/assembly_annotation_course/error_TEplot_%j.e
#SBATCH --account=class-sbl-30004-ws-2026
#SBATCH --reservation=class-sbl-30004-2026-10-21

set -euo pipefail

# Set paths
WORKDIR=/data/users/ejakobsson/assembly_annotation_course
COURSEDIR=/data/courses/genome_annotation_resources/2026
SIF="$COURSEDIR/containers/Annotation_analysis_R4.4.sif"

# Scripts
genome=assembly.fasta
SCRIPTDIR="$WORKDIR/scripts"
PLOTSCRIPT="$SCRIPTDIR/23-plot_div.R"
DATESCRIPT="$SCRIPTDIR/24-date_TEs.R"

# Everything is written here; plots go into the plots/ subfolder
OUTDIR="$WORKDIR/output/parseRM_TE_divergence"

# Landscape table (Rfam level) from the SAME parseRM run as the Rname table that 22-plot_div.R reads
LANDSCAPE="$WORKDIR/output/parseRM_TE_divergence/$genome.mod.EDTA.RM.nonzero.out.landscape.Div.Rfam.tab"

RATE=8.22e-9      # substitutions per site per year, Brassicaceae (Kagale et al. 2014)

# File check
for f in "$PLOTSCRIPT" "$DATESCRIPT" "$LANDSCAPE"; do
    [[ -e "$f" ]] || { echo "ERROR: missing file: $f" >&2; exit 1; }
done

mkdir -p "$OUTDIR/plots"
cd "$OUTDIR"

# Step 3: landscape plot (course script; writes to plots/ relative to the working directory)
apptainer exec -C --bind "$WORKDIR" --pwd "$OUTDIR" "$SIF" \
    Rscript --vanilla "$PLOTSCRIPT"

# Step 4: convert divergence bins to estimated insertion age, T = K / (2r)
apptainer exec -C --bind "$WORKDIR" --pwd "$OUTDIR" "$SIF" \
    Rscript --vanilla "$DATESCRIPT" "$LANDSCAPE" "$OUTDIR/TE_age" "$RATE"

# Put the age-landscape plot with the other plots (tables stay in OUTDIR)
mv -f "$OUTDIR/TE_age.landscape_age.pdf" "$OUTDIR/plots/"