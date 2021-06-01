

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
type <- variables[3]
population_variance <- variables[4]
critere <- variables[5]
programme <- variables[6]
progeny <- variables[7]


# 
# titre_best_crosses_cplex <- "/work2/genphyse/dynagen/adanguy/croisements/050321/best_crosses/crosses_filtered_g1_simTRUE_allcm_r5_WE_uc_extreme_real_raw.txt"
# titre_best_crosses <-  "/work2/genphyse/dynagen/adanguy/croisements/050321/best_crosses/best_crosses_g1_simTRUE_allcm_r5_WE_uc_extreme_real.txt"        
# generation <- 1                                                                                                                             
# type <- "marker_simTRUE_allcm_r5"                                                                                                        
# population <-  "WE"                                                                                                                             
# critere <- "uc_extreme"                                                                                                                     
# affixe <- "real" 



sim=gsub("sim","",as.vector(unlist(strsplit(type, split="_")))[1])


if (sim == "FALSE"){
  
  g=gsub("g","",as.vector(unlist(strsplit(type, split="_")))[2])
  h=NA
  r=NA
  qtls=NA
  
  etat="estimated"
  
  
  
} else if (sim=="TRUE") {
  
  
  if (grepl("_h", type)){
    
    qtls=as.vector(unlist(strsplit(type, split="_")))[2]
    h=gsub("h","",as.vector(unlist(strsplit(type, split="_")))[3])
    r=paste0(as.vector(unlist(strsplit(type, split="_")))[4],"r")
    g=gsub("g","",as.vector(unlist(strsplit(type, split="_")))[5])
    etat="estimated"
    
    
    
    
  } else if (!grepl("_h", type)) {
    
    qtls=as.vector(unlist(strsplit(type, split="_")))[2]
    r=paste0(as.vector(unlist(strsplit(type, split="_")))[3],"r")
    h=NA
    g=NA
    etat="real"
    
    
    
  }
  
  
}

best <- fread(titre_best_crosses_cplex) %>%
  rename(nbprogeny=value) %>%
  filter(nbprogeny>0) %>%
  mutate(nbprogeny=round(nbprogeny, 0)) %>%
  mutate(type=!!etat) %>%
  mutate(sim=!!sim) %>%
  mutate(qtls=!!qtls) %>%
  mutate(h=!!h) %>%
  mutate(r=!!r) %>%
  mutate(population_variance=!!population_variance) %>%
  mutate(critere=!!critere) %>%
  mutate(programme=!!programme) %>%
  mutate(progeny=!!progeny) %>%
  mutate(P1=unlist(strsplit(name, split="\\+"))[seq(1, nrow(.)*2, 2)]) %>%
  mutate(P2=unlist(strsplit(name, split="\\+"))[seq(2, nrow(.)*2, 2)]) %>% 
  dplyr::select(P1, P2, type, sim, qtls, h, r, population_variance, critere, programme, progeny, nbprogeny) %>%
  arrange(P1, P2)


cat("\n\nOUTPUT : variance of crosses and other performances \n\n")
head(best)
tail(best)
dim(best)
write_delim(best, titre_best_crosses, col_names = T, delim="\t", append = F, na="NA", quote_escape="none")




sessionInfo()
