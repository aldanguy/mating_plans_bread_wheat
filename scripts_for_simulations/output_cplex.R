

# Goal : Produce a standardized map for each population to compute variance-covariance matrix of progeny genotype
# Input : recombination profiles of several populations
# Output : standardized genetic map for each pop



Sys.time()
cat("\n\noutput_cplex.R\n\n")
rm(list = ls())
graphics.off()
set.seed(1)

suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(compiler))



variables <- commandArgs(trailingOnly=TRUE)
cat("\n\nVariables : \n")
print(variables)
cat("\n\n")

titre_best_crosses_gebv_cplex <- variables[1]
titre_crosses_best <- variables[2]


# titre_best_crosses_gebv_cplex="/work/adanguy/these/croisements/180121/best_crosses_gebv_raw.txt"
# titre_crosses_best="/work/adanguy/these/croisements/180121/best_crosses_gebv.txt"


best <- fread(titre_best_crosses_gebv_cplex) %>%
  rename(nbprogeny=value) %>%
  mutate(P1=unlist(strsplit(name, split="\\+"))[seq(1, nrow(.)*2, 2)]) %>%
  mutate(P2=unlist(strsplit(name, split="\\+"))[seq(2, nrow(.)*2, 2)]) %>%
  dplyr::select(P1, P2, nbprogeny) 


cat("\n\nOUTPUT : variance of crosses and other performances \n\n")
head(best)
dim(best)
write_delim(best, titre_crosses_best, col_names = T, delim="\t", append = F, na="NA", quote_escape="none")




sessionInfo()
