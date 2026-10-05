# Genome assembly course: analysis pipeline overview

This repository documents the genome assembly and evaluation pipeline for the
*Arabidopsis thaliana* (accession Db-1) assembly annotation course project.

## Author

## Data

- **PacBio HiFi reads** (`Db-1/`): used for genome assembly
- **Illumina RNAseq reads** (`RNAseq_Sha/`): paired-end reads, used for
  transcriptome assembly (Trinity)
- **Reference genome/annotation**: TAIR10 (*A. thaliana*), from
  `/data/courses/assembly-annotation-course/references`, used for
  reference-based evaluation (QUAST, nucmer)

## Pipeline Scripts

### Quality control & genome profiling

| Script | Purpose |
|---|---|
| `01_run_fastqc.sh` | Runs FastQC on raw HiFi and RNAseq reads to assess base quality, adapter content, and general read quality before assembly. |
| `02_kmer_counting.sh` | Runs `jellyfish count`/`histo` on HiFi reads to generate a k-mer frequency histogram, used with [GenomeScope](http://genomescope.org/genomescope2.0/) to estimate genome size and heterozygosity. These estimates informed downstream parameter choices (e.g. the `--diploid` decision for LJA, `--est-ref-size` for QUAST). |

### Genome & transcriptome assembly

| Script | Purpose |
|---|---|
| `03_flye_assembly.sh` | Assembles the genome from HiFi reads using Flye (`--pacbio-hifi`). |
| `04_hifiasm_assembly.sh` | Assembles the genome from HiFi reads using hifiasm; output `.gfa` converted to `.fa`. |
| `05_lja_assembly.sh` | Assembles the genome from HiFi reads using LJA. |
| `06_trinity_assembly.sh` | Assembles a transcriptome from Illumina RNAseq reads using Trinity. |

### Assembly evaluation

| Script | Purpose |
|---|---|
| `07_busco_flye.sh` | Runs BUSCO (genome mode, `brassicales_odb10`) on the Flye assembly to assess gene-content completeness. |
| `08_busco_hifiasm.sh` | Runs BUSCO (genome mode) on the hifiasm assembly. |
| `09_busco_trinity.sh` | Runs BUSCO (transcriptome mode) on the Trinity assembly. |
| `10_quast_with_ref.sh` | Runs QUAST on the Flye and hifiasm assemblies against the TAIR10 reference genome and annotation (`--features`). Reports contiguity (N50, contig count), genome fraction, misassemblies, and gene coverage. |
| `11_quast_no_ref.sh` | Runs QUAST on the same assemblies **without** the reference genome, using only the GenomeScope-derived genome size estimate (`--est-ref-size`). |
| `12_merqury.sh` | Runs Merqury (k=31, per tool recommendation) to assess assembly accuracy (QV score) and completeness via k-mer comparison between the HiFi reads and each assembly. |

### Structural comparison (dotplots)

| Script | Purpose |
|---|---|
| `13_comparison_ref.sh` | Runs `nucmer` + `mummerplot` to generate dotplots comparing each assembly (Flye, hifiasm) against the TAIR10 reference genome, visualizing structural concordance (collinearity, rearrangements, inversions). |
| `14_comparison_assemblies.sh` | Runs `nucmer` + `mummerplot` to generate dotplots comparing the assemblies directly against each other (Flye, hifiasm), independent of the reference. |

## Notes

- Due to an technical error in the LJA tool, an LJA assembly could not be successfully generated from accession Db-1, and the assembly was thus not used in any downstream analysis.