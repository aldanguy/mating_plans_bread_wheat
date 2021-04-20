

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
generation <- as.numeric(variables[3])
type <- variables[4]
population <- variables[5]
critere <- variables[6]
affixe <- variables[7]


# 
# titre_best_crosses_cplex <- "/work2/genphyse/dynagen/adanguy/croisements/050321/best_crosses/crosses_filtered_g1_simTRUE_allcm_r5_WE_uc_extreme_real_raw.txt"
# titre_best_crosses <-  "/work2/genphyse/dynagen/adanguy/croisements/050321/best_crosses/best_crosses_g1_simTRUE_allcm_r5_WE_uc_extreme_real.txt"        
# generation <- 1                                                                                                                             
# type <- "marker_simTRUE_allcm_r5"                                                                                                        
# population <-  "WE"                                                                                                                             
# critere <- "uc_extreme"                                                                                                                     
# affixe <- "real" 


best <- fread(titre_best_crosses_cplex) %>%
  rename(nbprogeny=value) %>%
  filter(nbprogeny>0) %>%
  mutate(nbprogeny=round(nbprogeny, 0)) %>%
  mutate(generation=!!generation) %>%
  mutate(type=!!type) %>%
  mutate(population=!!population) %>%
  mutate(affixe=!!affixe) %>%
  mutate(critere=!!critere) %>%
  mutate(P1=unlist(strsplit(name, split="\\+"))[seq(1, nrow(.)*2, 2)]) %>%
  mutate(P2=unlist(strsplit(name, split="\\+"))[seq(2, nrow(.)*2, 2)]) %>%
  dplyr::select(one_of("P1", "P2", "generation", "type", "population", "critere", "affixe", "nbprogeny"))  %>%
  arrange(P1, P2)


cat("\n\nOUTPUT : variance of crosses and other performances \n\n")
head(best)
dim(best)
write_delim(best, titre_best_crosses, col_names = T, delim="\t", append = F, na="NA", quote_escape="none")




sessionInfo()
