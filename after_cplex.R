

# Goal : Produce a standardized map for each population to compute variance-covariance matrix of progeny genotype
# Input : recombination profiles of several populations
# Output : standardized genetic map for each pop



Sys.time()
cat("\n\nafter_cplex.R\n\n")
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

titre_best_crosses_cplex <- variables[1]
titre_best_crosses <- variables[2]
generation_moins_un <- as.numeric(variables[3])
run <- as.numeric(variables[4])


# titre_best_crosses_gebv_cplex="/work/adanguy/these/croisements/180121/best_crosses_gebv_raw.txt"
# titre_best_crosses="/work/adanguy/these/croisements/180121/best_crosses_gebv.txt"


best <- fread(titre_best_crosses_cplex) %>%
  rename(nbprogeny=value) %>%
  filter(nbprogeny>0) %>%
  mutate(nbprogeny=round(nbprogeny, 0)) %>%
  mutate(generation=generation_moins_un) %>%
  mutate(run=run) %>%
  mutate(P1=unlist(strsplit(name, split="\\+"))[seq(1, nrow(.)*2, 2)]) %>%
  mutate(P2=unlist(strsplit(name, split="\\+"))[seq(2, nrow(.)*2, 2)]) %>%
  dplyr::select(P1, P2, nbprogeny, generation, run) 


cat("\n\nOUTPUT : variance of crosses and other performances \n\n")
head(best)
dim(best)
write_delim(best, titre_best_crosses, col_names = T, delim="\t", append = F, na="NA", quote_escape="none")




sessionInfo()
