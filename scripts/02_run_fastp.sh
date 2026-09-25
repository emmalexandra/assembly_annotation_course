#!/usr/bin/env bash

#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=02:00:00
#SBATCH --job-name=fastp
#SBATCH --mail-user=emma.jakobsson@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/ejakobsson/assembly_annotation_course/logs/output_fastp_%j.o
#SBATCH --error=/data/users/ejakobsson/assembly_annotation_course/logs/error_fastp_%j.e
#SBATCH --partition=pshort_el8

MODE=$1   # specify "rnaseq" or "hifi"  
WORKDIR=/data/users/ejakobsson/assembly_annotation_course/read_QC

# Trimming/filtering
if [ "$MODE" == "rnaseq" ]; then
    OUTDIR=$WORKDIR/fastp
    mkdir -p $OUTDIR
    apptainer exec --bind /data /containers/apptainer/fastp_0.24.1.sif \
        fastp -i $WORKDIR/RNAseq_Sha/*_1.fastq.gz -I $WORKDIR/RNAseq_Sha/*_2.fastq.gz \    # -i and -I: paired-end
        -o $OUTDIR/trimmed_1.fastq.gz -O $OUTDIR/trimmed_2.fastq.gz \                      # -o and -O: paired-end
        --thread 4 --json $OUTDIR/fastp_report.json --html $OUTDIR/fastp_report.html

# No filtering
elif [ "$MODE" == "hifi" ]; then
    OUTDIR=$WORKDIR/fastp
    mkdir -p $OUTDIR
    apptainer exec --bind /data /containers/apptainer/fastp_0.24.1.sif \
        fastp -i $WORKDIR/Db-1/*.fastq.gz \
        --thread 4 --disable_adapter_trimming --disable_quality_filtering --disable_length_filtering \
        --json $OUTDIR/fastp_report.json --html $OUTDIR/fastp_report.html

else
    echo "No mode specified. Usage: sbatch fastp.sh [rnaseq | hifi]"
    exit 1
fi