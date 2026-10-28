#!/bin/bash

#SBATCH --job-name=renamegenes
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=32G
#SBATCH --time=01:00:00
#SBATCH --mail-user=emma.jakobsson@students.unibe.ch
#SBATCH --mail-type=fail,end
#SBATCH --output=/data/users/ejakobsson/logs/assembly_annotation_course/output_renamegenes_%j.o
#SBATCH --error=/data/users/ejakobsson/logs/assembly_annotation_course/error_renamegenes_%j.e
#SBATCH --account=class-sbl-30004-ws-2026
#SBATCH --reservation=class-sbl-30004-2026-10-28

set -euo pipefail

# Paths
WORKDIR=/data/users/ejakobsson/assembly_annotation_course
COURSEDIR=/data/courses/genome_annotation_resources/2026
OUTDIR="$WORKDIR/output/MAKER"
FINALDIR="$OUTDIR/final"
MAKER_SIF="$COURSEDIR/containers/MAKER_3.01.03.sif"

protein="assembly.all.maker.proteins.fasta"
transcript="assembly.all.maker.transcripts.fasta"
gff="assembly.all.maker.noseq.gff"

# Accession: Db-1 but setting to DBX to avoid any confusion with numbers
prefix=DBX

mkdir -p "$FINALDIR/tmp"

# Make sure the merged inputs exist and are not empty
for f in "$gff" "$protein" "$transcript"; do
  if [ ! -s "$OUTDIR/$f" ]; then
    echo "ERROR: missing or empty input: $OUTDIR/$f" >&2
    exit 1
  fi
done

# Copy the merged files; the originals in $OUTDIR stay untouched
cp "$OUTDIR/$gff"        "$FINALDIR/${gff}.renamed.gff"
cp "$OUTDIR/$protein"    "$FINALDIR/${protein}.renamed.fasta"
cp "$OUTDIR/$transcript" "$FINALDIR/${transcript}.renamed.fasta"

cd "$FINALDIR"

run_maker_tool() {
  apptainer exec --cleanenv --env TMPDIR=/tmp \
    --bind "$OUTDIR/tmp":/tmp \
    --bind "$COURSEDIR" \
    --bind "$WORKDIR" \
    --pwd "$FINALDIR" "$MAKER_SIF" \
    "$@"
}

# 1) Create the ID map (written to stdout, so redirect it)
run_maker_tool maker_map_ids --prefix "$prefix" --justify 7 \
  "${gff}.renamed.gff" > id.map

# 2) Apply the map (these edit the files in place)
run_maker_tool map_gff_ids   id.map "${gff}.renamed.gff"
run_maker_tool map_fasta_ids id.map "${protein}.renamed.fasta"
run_maker_tool map_fasta_ids id.map "${transcript}.renamed.fasta"