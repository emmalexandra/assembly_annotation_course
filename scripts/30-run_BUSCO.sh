#!/bin/bash
#SBATCH --job-name=busco
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=03:00:00
#SBATCH --mail-user=emma.jakobsson@students.unibe.ch
#SBATCH --mail-type=fail,end
#SBATCH --output=/data/users/ejakobsson/logs/assembly_annotation_course/output_busco_%j.o
#SBATCH --error=/data/users/ejakobsson/logs/assembly_annotation_course/error_busco_%j.e
#SBATCH --account=class-sbl-30004-ws-2026
#SBATCH --reservation=class-sbl-30004-2026-10-28

set -euo pipefail

# Paths
WORKDIR=/data/users/ejakobsson/assembly_annotation_course
COURSEDIR=/data/courses/genome_annotation_resources/2026
FINALDIR="$WORKDIR/output/MAKER/final"          # filtered MAKER outputs
BUSCODIR="$WORKDIR/output/BUSCO"                # BUSCO results go here
ANALYSIS_SIF="$COURSEDIR/containers/Annotation_analysis_R4.4.sif"

protein="assembly.all.maker.proteins.fasta"
transcript="assembly.all.maker.transcripts.fasta"

mkdir -p "$BUSCODIR"

seqtool() {
  apptainer exec --cleanenv --bind "$COURSEDIR" --bind "$WORKDIR" \
    --pwd "$FINALDIR" "$ANALYSIS_SIF" "$@"
}

# 1) Longest isoform per gene (gene ID = mRNA ID without the -RA/-RB suffix)
cd "$FINALDIR"
for f in "$protein" "$transcript"; do
  in="${f}.renamed.filtered.fasta"
  out="${f}.renamed.longest.fasta"
  seqtool seqkit fx2tab -n -i -l "$in" \
    | awk '{g=$1; sub(/-R[A-Z]+$/,"",g);
            if(!(g in len) || $2>len[g]){len[g]=$2; id[g]=$1}}
           END{for(g in id) print id[g]}' > "${f}.longest.list"
  seqtool seqkit grep -f "${f}.longest.list" "$in" -o "$out"
  echo "$out: $(grep -c '>' "$out") sequences"
done

# 2) BUSCO
module load BUSCO/5.4.2-foss-2021a
export PYTHONNOUSERSITE=1
cd "$BUSCODIR"

busco -i "$FINALDIR/${protein}.renamed.longest.fasta" \
  -l brassicales_odb10 -o busco_proteins -m proteins -c "$SLURM_CPUS_PER_TASK"

busco -i "$FINALDIR/${transcript}.renamed.longest.fasta" \
  -l brassicales_odb10 -o busco_transcripts -m transcriptome -c "$SLURM_CPUS_PER_TASK"