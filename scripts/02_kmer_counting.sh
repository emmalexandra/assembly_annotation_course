#!/usr/bin/env bash

#SBATCH --cpus-per-task=4
#SBATCH --mem=64G
#SBATCH --time=02:00:00
#SBATCH --job-name=jellyfish
#SBATCH --mail-user=emma.jakobsson@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/ejakobsson/assembly_annotation_course/logs/jellyfish_%j.o
#SBATCH --error=/data/users/ejakobsson/assembly_annotation_course/logs/jellyfish_%j.e
#SBATCH --partition=pshort_el8

WORKDIR=/data/users/ejakobsson/assembly_annotation_course
OUTDIR=$WORKDIR/read_QC/kmer_counting_jellyfish
mkdir -p $OUTDIR

apptainer exec \
--bind /data \
/containers/apptainer/jellyfish-2.2.6--0.sif \
jellyfish count \
-C -m 31 -s 5G -t 4 \
<(zcat $WORKDIR/Db-1/*.fastq.gz) \
-o $OUTDIR/reads.jf

apptainer exec \
--bind /data \
/containers/apptainer/jellyfish-2.2.6--0.sif \
jellyfish histo \
-t 4 \
$OUTDIR/reads.jf > $OUTDIR/reads.histo