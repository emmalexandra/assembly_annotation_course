#!/usr/bin/env Rscript

# Convert the parseRM.pl landscape table (Rfam level, 1% divergence bins) into estimated
# TE ages using T = K / (2r), with K = divergence (fraction) and r = substitution rate/site/year.

# Usage: Rscript --vanilla date_TEs.R <*.landscape.Div.Rfam.tab> <out_prefix> [rate = 8.22e-9]

suppressPackageStartupMessages(library(tidyverse))

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2) stop("Usage: Rscript date_TEs.R <landscape.Div.Rfam.tab> <out_prefix> [rate]")
infile     <- args[1]
out_prefix <- args[2]
rate       <- if (length(args) >= 3) as.numeric(args[3]) else 8.22e-9  # Kagale et al. 2014

# Divergence in % -> age in million years
div_to_My <- function(div_pct) (div_pct / 100) / (2 * rate) / 1e6

# Read landscape table: line 1 is a title line, line 2 the header (Rclass, Rfam, [0;1[, ...)
raw <- read.table(infile, sep = "\t", header = TRUE, skip = 1, check.names = FALSE,
                  quote = "", comment.char = "", stringsAsFactors = FALSE)

bin_cols <- colnames(raw)[-(1:2)]
m <- str_match(bin_cols, "^\\[([0-9.]+);([0-9.]+)\\[$")
if (anyNA(m)) stop("Unexpected bin labels in header: ", paste(head(bin_cols), collapse = " "))
bins <- tibble(bin = bin_cols, div_start = as.numeric(m[, 2]), div_end = as.numeric(m[, 3]))

long <- raw %>%
  rename(Rclass = 1, Rfam = 2) %>%
  mutate(superfamily = paste(Rclass, Rfam, sep = "/")) %>%
  pivot_longer(all_of(bin_cols), names_to = "bin", values_to = "bp") %>%
  left_join(bins, by = "bin") %>%
  mutate(div_mid      = (div_start + div_end) / 2,
         age_start_My = div_to_My(div_start),
         age_end_My   = div_to_My(div_end),
         age_mid_My   = div_to_My(div_mid))

# 1) Full table: bp per superfamily per divergence bin, with age of each bin
long %>%
  select(superfamily, bin, div_start, div_end, age_start_My, age_end_My, age_mid_My, bp) %>%
  write_tsv(paste0(out_prefix, ".by_bin.tsv"))

# 2) Summary per superfamily: total amount and bp-weighted median age
wmedian <- function(x, w) {
  if (sum(w) == 0) return(NA_real_)
  o <- order(x); x <- x[o]; w <- w[o]
  x[which(cumsum(w) >= sum(w) / 2)[1]]
}
summ <- long %>%
  group_by(superfamily) %>%
  summarise(total_Mb = sum(bp) / 1e6,
            median_age_My = wmedian(age_mid_My, bp), .groups = "drop") %>%
  arrange(desc(total_Mb))
write_tsv(summ, paste0(out_prefix, ".summary.tsv"))
print(summ, n = 30)

# 3) Landscape plot with a second axis in My (top 8 superfamilies, rest = Other)
top <- summ$superfamily[seq_len(min(8, nrow(summ)))]
p <- long %>%
  mutate(superfamily = if_else(superfamily %in% top, superfamily, "Other")) %>%
  group_by(superfamily, div_mid) %>%
  summarise(bp = sum(bp), .groups = "drop") %>%
  ggplot(aes(div_mid, bp / 1e6, fill = superfamily)) +
  geom_col(width = 0.9) +
  scale_x_continuous(name = "Divergence from library consensus (%)",
                     sec.axis = sec_axis(~ . / (200 * rate * 1e6), name = "Estimated age (My)")) +
  labs(y = "Genome covered (Mb)", fill = "Superfamily") +
  theme_bw()
ggsave(paste0(out_prefix, ".landscape_age.pdf"), p, width = 9, height = 5)

cat("Wrote:", paste0(out_prefix, c(".by_bin.tsv", ".summary.tsv", ".landscape_age.pdf")), "\n")