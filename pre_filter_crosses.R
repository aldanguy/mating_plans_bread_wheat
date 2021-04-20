



# Goal : gather data
# Input : blupf90 outputs, gebv and snp effects
# Output : files updated



Sys.time()
cat("\n\npre_filter_crosses.R\n\n")
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

titre_crosses <- variables[1]
Pmax <- as.numeric(variables[2])
Kmax <- as.numeric(variables[3])
Cmax <- as.numeric(variables[4])
Kmin <- as.numeric(variables[5])
colonne <- variables[6]
titre_crosses_filtered  <- variables[7]

# titre_crosses <-  "/work2/genphyse/dynagen/adanguy/croisements/050321/value_crosses/crosses/crosses_g1_simFALSE_10cm_WE.txt"                
# Pmax <- 132                                                                                                               
# Kmax <-  300                                                                                                                     
# Cmax <- 250                                                                                                                     
# Kmin <- 200                                                                                                                     
# colonne <-  "gebv"                                                                                                                    
# titre_crosses_filtered  <-  "/work2/genphyse/dynagen/adanguy/croisements/050321/best_crosses/crosses_filtered_g1_simFALSE_10cm_WE_gebv_real_test2.txt"
# 
# 


cat("\n\n INPUT : crosses \n\n")
crosses <- fread(titre_crosses)
head(crosses)
tail(crosses)
dim(crosses)


factor <- 20
Pmax2 = 2*Kmax # if variable Pmax is set to infinite
Pmax3 = 2*2*Kmin # if both Pmax and Kmax are set to infinite


if (colonne !="logw"){

crosses <- crosses %>%  arrange(P1, P2) %>% arrange_at(colonne, desc)

liste_parents <- crosses %>% dplyr::select(P1, P2) %>%
  unlist() %>% unique() %>% as.vector() 


liste_parents_kept <- liste_parents[1:min(min(c(Pmax+factor), Pmax2 +factor, Pmax3 + factor), length(liste_parents))]

crosses_filtered <- crosses %>% filter(P1 %in% liste_parents_kept | P2 %in% liste_parents_kept) %>%  #filter 1
  arrange_at(colonne, desc) %>%
  group_by(P1) %>%
  mutate(nP1=1:n()) %>%
  ungroup() %>% 
  group_by(P2) %>% 
  mutate(nP2=1:n()) %>%
  ungroup() %>%
  filter(nP1 <= (Cmax +factor) & nP2 <= (Cmax + factor)) %>%  #filter 2
  arrange(P1, P2) %>%
  arrange_at(colonne, desc) %>%
  dplyr::select(P1, P2, generation, type, population, one_of(colonne)) %>%
  as.data.frame()

} else {
  
  crosses <- crosses %>%  arrange(P1, P2) %>% arrange_at(colonne)
  
  liste_parents <- crosses %>% dplyr::select(P1, P2) %>%
    unlist() %>% unique() %>% as.vector() 
  
  
  liste_parents_kept <- liste_parents[1:min(min(c(Pmax+factor), Pmax2 +factor, Pmax3 + factor), length(liste_parents))]
  
  crosses_filtered <- crosses %>% filter(P1 %in% liste_parents_kept | P2 %in% liste_parents_kept) %>%  #filter 1
    arrange_at(colonne) %>%
    group_by(P1) %>%
    mutate(nP1=1:n()) %>%
    ungroup() %>% 
    group_by(P2) %>% 
    mutate(nP2=1:n()) %>%
    ungroup() %>%
    filter(nP1 <= (Cmax +factor) & nP2 <= (Cmax + factor)) %>%  #filter 2
    arrange(P1, P2) %>%
    arrange_at(colonne) %>%
    dplyr::select(P1, P2, generation, type, population, one_of(colonne)) %>%
    as.data.frame()
  
}



# crosses_filtered <- crosses %>% filter(P1 %in% liste_parents_kept | P2 %in% liste_parents_kept) %>% # filter 1
#   arrange_at(colonne, desc) %>%
#   group_by(P1) %>%
#   mutate(nP1=1:n()) %>%
#   ungroup() %>% 
#   group_by(P2) %>% 
#   mutate(nP2=1:n()) %>%
#   ungroup() %>%
#   arrange(P1, P2) %>%
#   arrange_at(colonne, desc) %>%
#   dplyr::select(P1, P2, generation, type, population, one_of(colonne)) %>%
#   as.data.frame()



cat("\n\n Percentage of crosses kept: \n")
round(nrow(crosses_filtered)/nrow(crosses),2)


# Filter 1
# order crosses based on a criteria (uc)
# keep the Pmax first parents in the dataframe


# filter 2
# if all crosses have only one progeny (Dmin), a good parent will not be choosen more than Cmax times
# thus, keep top crosses whose parents appear less than Cmax times 


cat("\n\n OUTPUT : crosses filtered \n\n")
head(crosses_filtered)
tail(crosses_filtered)
dim(crosses_filtered)

write.table(crosses_filtered, titre_crosses_filtered, col.names=T, row.names=F, dec=".", sep="\t", quote=F)


sessionInfo()