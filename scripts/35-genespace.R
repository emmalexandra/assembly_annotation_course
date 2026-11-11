#!/usr/bin/env Rscript

library(GENESPACE)

args <- commandArgs(trailingOnly = TRUE)

# folder that is the GENESPACE working directory (contains bed/ and peptide/)
wd <- args[1]

gpar <- init_genespace(
  wd = wd,
  path2mcscanx = "/usr/local/bin",
  nCores = 20
)

# run genespace
out <- run_genespace(gpar)

pangenome <- query_pangenes(
  out,
  bed = NULL,
  refGenome = "TAIR10",
  transform = TRUE,
  showArrayMem = TRUE,
  showNSOrtho = TRUE,
  maxMem2Show = Inf
)

# save pangenome object as rds
saveRDS(pangenome, file = file.path(wd, "pangenome_matrix.rds"))