#!/bin/bash
#SBATCH --job-name=parsem
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16GB
#SBATCH --time=01:00:00
#SBATCH --mail-user=emma.jakobsson@students.unibe.ch
#SBATCH --mail-type=fail,end
#SBATCH --output=/data/users/ejakobsson/logs/assembly_annotation_course/output_parsem_%j.o
#SBATCH --error=/data/users/ejakobsson/logs/assembly_annotation_course/error_parsem_%j.e
#SBATCH --account=class-sbl-30004-ws-2026
#SBATCH --reservation=class-sbl-30004-2026-10-21

# Stop on failed commands, unset variables, or failures within pipelines.
set -euo pipefail
 
# Shared course software and your project folder
COURSEDIR=/data/courses/genome_annotation_resources/2026
WORKDIR=/data/users/ejakobsson/assembly_annotation_course
 
# Container with perl, R 4.4 and the course scripts' dependencies
R_SIF="$COURSEDIR/containers/Annotation_analysis_R4.4.sif"
 
# EDTA annotation folder that contains the RepeatMasker output (input, left untouched)
genome=assembly.fasta
ANNODIR="$WORKDIR/output/EDTA_copy/$genome.mod.EDTA.anno"
 
# Separate output folder for the filtered file and the landscape tables
OUTDIR="$WORKDIR/output/parseRM_TE_divergence"
 
# Prevent inherited container settings from changing the course environment.
unset SINGULARITY_BIND APPTAINER_BIND
 
mkdir -p "$OUTDIR"
cd "$OUTDIR"
 
# Step 1: remove hits with 0% divergence (column 2), which can be the
# library copy matching itself. NR == 1 keeps the first header line.
# Reads from the EDTA folder, writes the filtered file into OUTDIR.
awk 'NR == 1 || $2 != 0' "$ANNODIR/$genome.mod.EDTA.RM.out" \
    > "$genome.mod.EDTA.RM.nonzero.out"
 
# Step 2: bin divergence values in 1% steps (up to 50%) per TE superfamily.
# parseRM writes its tables next to the input file, so they also land in OUTDIR.
#   -i  input file
#   -l  max divergence, bin size
#   -v  verbose
apptainer exec -C --bind "$WORKDIR" --bind "$COURSEDIR" --pwd "$OUTDIR" "$R_SIF" \
    perl "$COURSEDIR/scripts/05-parseRM.pl" \
        -i "$genome.mod.EDTA.RM.nonzero.out" \
        -l 50,1 \
        -v