

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
titre_crosses_input <- variables[2]
criterion <- variables[3]
titre_best_crosses_output <- variables[4]



# 
# titre_best_crosses_cplex <- "/work2/genphyse/dynagen/adanguy/croisements/050321/best_crosses/crosses_filtered_g1_simTRUE_allcm_r5_WE_uc_extreme_real_raw.txt"
# titre_best_crosses <-  "/work2/genphyse/dynagen/adanguy/croisements/050321/best_crosses/best_crosses_g1_simTRUE_allcm_r5_WE_uc_extreme_real.txt"        
# generation <- 1                                                                                                                             
# type <- "marker_simTRUE_allcm_r5"                                                                                                        
# population <-  "WE"                                                                                                                             
# critere <- "uc_extreme"                                                                                                                     
# affixe <- "real" 

cat("\n\n crosses from CPLEX \n\n")
best <- fread(titre_best_crosses_cplex) 
head(best)
tail(best)
dim(best)


cat("\n\n crosses  \n\n")
crosses <- fread(titre_crosses_input) 
head(crosses)
tail(crosses)
dim(crosses)

m <- best %>%
  rename(nbprogeny=value) %>%
  mutate(nbprogeny=round(nbprogeny, 0)) %>%
  filter(nbprogeny>0) %>%
  mutate(P1=unlist(strsplit(name, split="\\+"))[seq(1, nrow(.)*2, 2)]) %>%
  mutate(P2=unlist(strsplit(name, split="\\+"))[seq(2, nrow(.)*2, 2)]) %>% 
  inner_join(crosses%>% dplyr::select(P1, P2, genetic_map, simulation, qtls, qtls_info, heritability, genomic, population, progeny, population_ID, CONSTRAINTS),
             by=c("P1","P2")) %>%
  mutate(criterion=!!criterion) %>%
  dplyr::select(P1, P2, genetic_map, simulation, qtls, qtls_info, heritability, genomic, population, progeny, population_ID, CONSTRAINTS, criterion, nbprogeny) %>%
  arrange(P1, P2)


  

cat("\n\nOUTPUT : mating plan \n\n")
head(m)
tail(m)
dim(m)
write_delim(m, titre_best_crosses_output, col_names = T, delim="\t", append = F, na="NA", quote_escape="none")




sessionInfo()
