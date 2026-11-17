#!/usr/bin/env Rscript

library(GENESPACE)

wd <- "/data/users/ejakobsson/assembly_annotation_course/output/comparisons/GENESPACE"
focal_genome <- "Db_1"

load(file.path(wd, "results", "gsParams.rda"))   # loads gsParam
dir.create(file.path(wd, "processed_riparian"), showWarnings = FALSE)

# --- Pass 1: Db_1 vs TAIR10, scaffolds ordered by synteny
plot_riparian(
  gsParam,
  genomeIDs = c("TAIR10", focal_genome),
  refGenome = "TAIR10",
  reorderBySynteny = TRUE,
  pdfFile = file.path(wd, "processed_riparian", "Db_1_vs_TAIR10.pdf")
)

# --- Pass 2: flip scaffolds that are drawn in reverse (fill in after pass 1)
flips <- data.frame(
  genome = "Db_1",
  chr = c("contig_160", "contig_228", "contig_121", "contig_97",
          "contig_96", "contig_135", "contig_236", "contig_202", "contig_218", "contig_126")
)

plot_riparian(
  gsParam,
  genomeIDs = c("TAIR10", focal_genome),
  refGenome = "TAIR10",
  reorderBySynteny = TRUE,
  syntenyWeight = 1,
  invertTheseChrs = flips,
  pdfFile = file.path(wd, "processed_riparian", "Db_1_vs_TAIR10_oriented.pdf")
)

# --- All five genomes
plot_riparian(
  gsParam,
  refGenome = "TAIR10",
  reorderBySynteny = TRUE,
  syntenyWeight = 1,
  invertTheseChrs = flips,
  scalePlotWidth = 1.5,
  pdfFile = file.path(wd, "processed_riparian", "all_genomes_TAIR10.pdf")
)