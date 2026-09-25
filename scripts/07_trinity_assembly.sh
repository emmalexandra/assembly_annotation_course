#!/usr/bin/env bash

#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=1-00:00:00
#SBATCH --job-name=trinity
#SBATCH --mail-user=emma.jakobsson@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/ejakobsson/assembly_annotation_course/logs/output_trinity_%j.o
#SBATCH --error=/data/users/ejakobsson/assembly_annotation_course/logs/error_trinity_%j.e
#SBATCH --partition=pibu_el8

# Loading Trinity from module (check available module: module avail Trinity)
module load Trinity/2.15.1-foss-2021a

WORKDIR=/data/users/ejakobsson/assembly_annotation_course
OUTDIR=$WORKDIR/assemblies/trinity

mkdir -p $OUTDIR

Trinity --seqType fq \
--left $WORKDIR/RNAseq_Sha/*_1.fastq.gz \
--right $WORKDIR/RNAseq_Sha/*_2.fastq.gz \
--CPU 16 --max_memory 64G \
--output $OUTDIR
