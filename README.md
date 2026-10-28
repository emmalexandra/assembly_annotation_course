# Assembly and annotation of Eukaryotic genomes

## Author: Emma Jakobsson

## Content
* **Part I**: (Scripts 01-14): Genome Assembly course
* **Part II** (Scripts 15-31): Annotation and Organisation of Eukaryote genomes


# Part I: Genome assembly course

This repository documents the genome assembly and evaluation pipeline for the
*Arabidopsis thaliana* (accession Db-1) Genome and transcriptome assembly course project.

## Data
Data obtained from: 
Qichao Lian et al. **A pan-genome of 69 Arabidopsis thaliana accessions reveals a conserved genome structure throughout the global species range**. *Nature Genetics*. 2024;56:982-991. 
Available from: https://www.nature.com/articles/s41588-024-01715-9

Jiao WB, Schneeberger K. **Chromosome-level assemblies of multiple Arabidopsis genomes reveal hotspots of rearrangements with altered evolutionary dynamics**. *Nature Communications*. 2020;11:1–10. 
Available from: http://dx.doi.org/10.1038/s41467-020-14779-y

- **PacBio HiFi reads** (Accession `Db-1/`): used for genome assembly
- **Illumina RNAseq reads** (`RNAseq_Sha/`): paired-end reads, used for transcriptome assembly (Trinity)
- **Reference genome/annotation**: TAIR10 (*A. thaliana*), from
  `/data/courses/assembly-annotation-course/references`, used for
  reference-based evaluation (QUAST, nucmer)

## Scripts

### Quality control & genome profiling

| Script | Purpose |
|---|---|
| `01_run_fastqc.sh` | Runs [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) on raw HiFi and RNAseq reads to assess base quality, adapter content, and general read quality before assembly. |
| `02_kmer_counting.sh` | Runs `jellyfish count`/`histo` on HiFi reads to generate a k-mer frequency histogram, used with [GenomeScope](http://genomescope.org/genomescope2.0/) to estimate genome size and heterozygosity. These estimates informed downstream parameter choices (e.g. the `--diploid` decision for LJA, `--est-ref-size` for QUAST). |

### Genome & transcriptome assembly

| Script | Purpose |
|---|---|
| `03_flye_assembly.sh` | Assembles the genome from HiFi reads using [Flye](https://github.com/mikolmogorov/Flye) (`--pacbio-hifi`). |
| `04_hifiasm_assembly.sh` | Assembles the genome from HiFi reads using [hifiasm](https://github.com/chhylp123/hifiasm); output `.gfa` converted to `.fa`. |
| `05_lja_assembly.sh` | Assembles the genome from HiFi reads using [LJA](https://github.com/AntonBankevich/LJA/blob/main/docs/lja_manual.md). |
| `06_trinity_assembly.sh` | Assembles a transcriptome from Illumina RNAseq reads using [Trinity](https://github.com/trinityrnaseq/trinityrnaseq/wiki). |

### Assembly evaluation

| Script | Purpose |
|---|---|
| `07_busco_flye.sh` | Runs [BUSCO](https://busco.ezlab.org/busco_userguide.html) (genome mode, `brassicales_odb10`) on the Flye assembly to assess gene-content completeness. |
| `08_busco_hifiasm.sh` | Runs BUSCO (genome mode) on the hifiasm assembly. |
| `09_busco_trinity.sh` | Runs BUSCO (transcriptome mode) on the Trinity assembly. |
| `10_quast_with_ref.sh` | Runs [QUAST](https://quast.sourceforge.net/) on the Flye and hifiasm assemblies against the TAIR10 reference genome and annotation (`--features`). Reports contiguity (N50, contig count), genome fraction, misassemblies, and gene coverage. |
| `11_quast_no_ref.sh` | Runs QUAST on the same assemblies **without** the reference genome, using only the GenomeScope-derived genome size estimate (`--est-ref-size`). |
| `12_merqury.sh` | Runs [Merqury](https://github.com/marbl/merqury) (k=31, per tool recommendation) to assess assembly accuracy (QV score) and completeness via k-mer comparison between the HiFi reads and each assembly. |

### Structural comparison (dotplots)

| Script | Purpose |
|---|---|
| `13_comparison_ref.sh` | Runs `nucmer` + `mummerplot` using [MUMmer](https://mummer4.github.io/manual/manual.html) to generate dotplots comparing each assembly (Flye, hifiasm) against the TAIR10 reference genome, visualizing structural concordance (collinearity, rearrangements, inversions). |
| `14_comparison_assemblies.sh` | Runs `nucmer` + `mummerplot` to generate dotplots comparing the assemblies directly against each other (Flye, hifiasm), independent of the reference. |

## Notes

- Due to an technical error in the LJA tool, an LJA assembly could not be successfully generated from accession Db-1, and the assembly was thus not used in any downstream analysis.
- Some kind of error with EDTA tool: no Gypsy and very few Copia detected (most marked simply as "unknown")



# Part II: Annotation and Organisation of Eukaryote genomes

## Scripts

### Transposable element annotation

| Script | Purpose |
|---|---|
| `15-run_EDTA.sh` | Runs [EDTA](https://github.com/oushujun/EDTA) (`--sensitive 1`, `--anno 1`, with the TAIR10 CDS file for purging gene sequences) to build a non-redundant TE library and a whole-genome TE annotation (`TElib.fa`, `TEanno.gff3`, `TEanno.sum`). |
| `16-<name>.sh` | *(name hidden in screenshot, fill in)* |
| `17-generate_LTR_plots.sh` | Plots the LTR-LTR identity distributions of full-length Copia and Gypsy elements (pooled and per clade), using the intact LTR set and the TEsorter clade classification. |
| `18-run_circlize.sh` | Runs the circlize analysis that prepares the genome-wide TE and gene density data for the circular plot. |
| `19-annotation_circlize.R` | R script that draws the circular (circlize) overview of the annotation across the largest contigs. |
| `20-run_TEsorter_Gypsy_Copia.sh` | Classifies the intact LTR retrotransposons from EDTA to clade level with [TEsorter](https://github.com/zhangrengang/TEsorter) (`rexdb-plant` database), separating Copia and Gypsy. |
| `21-run_parsem.sh` | Runs `parseRM.pl` on the RepeatMasker output to produce the divergence landscape tables (1% bins) used for TE dating. |
| `22-run_TE_plot_dating.sh` | Runs the TE landscape plotting and dating scripts on the `parseRM` output. |
| `23-plot_div.R` | R script that plots the TE divergence landscape by superfamily. |
| `24-date_TEs.R` | Converts divergence from library consensus to estimated insertion age with T = K / 2r (default r = 8.22e-9 substitutions/site/year, Kagale et al. 2014), writes per-bin and per-superfamily tables, and draws the landscape with a second age axis (My). |

### Gene annotation

| Script | Purpose |
|---|---|
| `25-run_maker.sh` | Runs [MAKER](https://www.yandell-lab.org/software/maker.html) (3.01.03, MPI in an Apptainer container) using the Trinity transcriptome (`est`), TAIR10 and UniProt Viridiplantae proteins, the EDTA TE library (`rmlib`) and the Augustus *arabidopsis* model, with `est2genome` and `protein2genome` enabled. |
| `26-merge_GFF_files.sh` | Merges the per-contig MAKER results from the master datastore index with `gff3_merge` and `fasta_merge`, giving the merged GFF (with and without sequence) and the protein and transcript FASTA files. |
| `27-rename_genes.sh` | Copies the merged files to `output/MAKER/final` and assigns consistent gene, transcript and protein IDs (prefix `DBX`, zero-padded to 7 digits) with `maker_map_ids`, `map_gff_ids` and `map_fasta_ids`. Writes the old-to-new `id.map`. |
| `28-run_interproscan.sh` | Runs [InterProScan](https://github.com/ebi-pf-team/interproscan) 5.70 (Pfam only, with GO terms) on the renamed protein sequences to find protein domains. |
| `29-filter_annotations.sh` | Adds the InterProScan results to the GFF (`ipr_update_gff`), computes the cumulative AED distribution, keeps models with AED < 1 and/or a Pfam domain (`quality_filter.pl`), restricts the GFF to gene, mRNA, exon, CDS and UTR features, and extracts the matching filtered protein and transcript FASTA files. |
| `30-run_BUSCO.sh` | Produces the longest-isoform-per-gene FASTA files. Runs [BUSCO](https://busco.ezlab.org/) 5.4.2 (`brassicales_odb10`) on the longest protein and transcript sequences per gene to assess annotation completeness. |
| `31-run_AGAT.sh` | Runs `agat_sp_statistics.pl` ([AGAT](https://github.com/NBISweden/AGAT) 1.4.1) on the final filtered GFF3 to report gene, mRNA, exon and intron counts and lengths. |


## Notes
- Due to a bug in the EDTA tool, no Gypsy and very few Copia detected (marked instead as "unknown").