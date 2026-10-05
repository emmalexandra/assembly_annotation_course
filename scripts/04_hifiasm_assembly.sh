#!/usr/bin/env bash

#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=1-00:00:00
#SBATCH --job-name=hifiasm
#SBATCH --mail-user=emma.jakobsson@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/ejakobsson/assembly_annotation_course/logs/output_hifiasm_%j.o
#SBATCH --error=/data/users/ejakobsson/assembly_annotation_course/logs/error_hifiasm_%j.e
#SBATCH --partition=pibu_el8

WORKDIR=/data/users/ejakobsson/assembly_annotation_course
OUTDIR=$WORKDIR/assemblies/hifiasm

mkdir -p $OUTDIR

# Output file name as 'Db-1'. Change accordingly.
apptainer exec \
--bind /data \
/containers/apptainer/hifiasm_0.25.0.sif \
hifiasm -o $OUTDIR/Db-1 -t 16 $WORKDIR/Db-1/*.fastq.gz

# Converting GFA to FASTA
awk '/^S/{print ">"$2;print $3}' $OUTDIR/Db-1.bp.p_ctg.gfa > $OUTDIR/Db-1.bp.p_ctg.fa