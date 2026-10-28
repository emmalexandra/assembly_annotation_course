#!/bin/bash
#SBATCH --job-name=Maker_gene_annotation
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --mem=64G
#SBATCH --time=7-00:00:00
#SBATCH --mail-user=emma.jakobsson@students.unibe.ch
#SBATCH --mail-type=fail,end
#SBATCH --output=/data/users/ejakobsson/logs/assembly_annotation_course/output_maker_%j.o
#SBATCH --error=/data/users/ejakobsson/logs/assembly_annotation_course/error_maker_%j.e

set -euo pipefail

COURSEDIR=/data/courses/genome_annotation_resources/2026
WORKDIR=/data/users/ejakobsson/assembly_annotation_course
OUTDIR="$WORKDIR/output/MAKER"
MAKER_SIF="$COURSEDIR/containers/MAKER_3.01.03.sif"
AUGUSTUS_CONFIG_PATH="$COURSEDIR/tools/MAKER/augustus_config"

# Before submitting, copy the four templates from:
# /data/courses/genome_annotation_resources/2026/tools/MAKER/control_files/
# into your project root, then edit maker_opts.ctl:
# genome = your genome FASTA; est = your Trinity FASTA; rmlib = your EDTA TE library.
# Protein references already point to the course directory.
# Submit from the project root: sbatch scripts/XX-run_maker.sh
# The copy below uses YOUR EDITED project files, then runs MAKER in output/MAKER.
unset SINGULARITY_BIND APPTAINER_BIND SINGULARITY_TMPDIR
mkdir -p "$OUTDIR/tmp"
cp "$WORKDIR/control_files/maker_opts.ctl" \
    "$WORKDIR/control_files/maker_bopts.ctl" \
    "$WORKDIR/control_files/maker_exe.ctl" \
    "$WORKDIR/control_files/maker_evm.ctl" \
    "$OUTDIR/"
cd "$OUTDIR"


# Use the container's MPICH launcher; keep cpus=1 in maker_opts.ctl.
apptainer exec --cleanenv --env AUGUSTUS_CONFIG_PATH="$AUGUSTUS_CONFIG_PATH" \
    --bind /data --bind "$WORKDIR" --bind "$OUTDIR/tmp":/TMP \
    --pwd "$OUTDIR" "$MAKER_SIF" \
    mpiexec -launcher fork -n "$SLURM_CPUS_PER_TASK" \
    maker -mpi --ignore_nfs_tmp -TMP /TMP \
    maker_opts.ctl maker_bopts.ctl maker_exe.ctl maker_evm.ctl
