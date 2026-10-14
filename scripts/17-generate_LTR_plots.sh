#!/bin/bash
#SBATCH --job-name=LTR_plots
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=4GB
#SBATCH --time=01:00:00
#SBATCH --mail-user=emma.jakobsson@students.unibe.ch
#SBATCH --mail-type=fail,end
#SBATCH --output=/data/users/ejakobsson/logs/assembly_annotation_course/output_LTR_plots_%j.o
#SBATCH --error=/data/users/ejakobsson/logs/assembly_annotation_course/error_LTR_plots_%j.e
#SBATCH --account=class-sbl-30004-ws-2026
#SBATCH --reservation=class-sbl-30004-2026-10-14

# Run the R script in the output directory of script 16-run_TEsorter_full_length_LTRs.sh:
COURSEDIR=/data/courses/genome_annotation_resources/2026
WORKDIR=/data/users/ejakobsson/assembly_annotation_course
cd "$WORKDIR/output/LTR_full_length"

apptainer exec -C \
  --bind "$WORKDIR" \
  --bind "$COURSEDIR" \
  --pwd "$PWD" \
  "$COURSEDIR/containers/Annotation_analysis_R4.4.sif" \
  Rscript --vanilla "$COURSEDIR/scripts/03-full_length_LTRs_identity_copy.R"