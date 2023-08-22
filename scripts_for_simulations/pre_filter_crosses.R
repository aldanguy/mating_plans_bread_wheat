



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
colonnei <- variables[6]
titre_crosses_filtered  <- variables[7]
progeny <- variables[8]

# titre_crosses <- "/work2/genphyse/dynagen/adanguy/croisements/200421/value_crosses/crosses/crosses_simFALSE_gbasic_WE.txt"          
# Pmax <- 132                                                                                                            
# Kmax <- 300                                                                                                          
# Cmax <-250                                                                                                              
# Kmin <- 200                                                                                                             
# colonnei <-  "logw"                                                                                                             
# titre_crosses_filtered  <-"/work2/genphyse/dynagen/adanguy/croisements/200421/best_crosses/crosses_filtered_simFALSE_gbasic_WE_logw_real.txt"
# 


cat("\n\n INPUT : crosses \n\n")
crosses <- fread(titre_crosses)
head(crosses)
tail(crosses)
dim(crosses)





selfing=as.numeric(as.vector(unlist(strsplit(split="F", progeny)))[2])
progeny2=as.vector(unlist(strsplit(split="F", progeny)))[1]




factor <- round(0.5*Pmax)
Pmax2 = 2*Kmax # if variable Pmax is set to infinite


if (colonnei =="embv" | colonnei == "topq"){
  
  colonne <- "uc"
} else {
  
  colonne <- colonnei
}


if (colonne !="logw"){

crosses <- crosses %>%  arrange(P1, P2) %>% 
  rename_at(vars(matches(paste0("sd_",progeny2))), ~ "sd") %>%
  rename_at(vars(matches(paste0("uc_extreme_",progeny2))), ~ "ucextreme") %>%
  rename_at(vars(matches(paste0("uc_",progeny2))), ~ "uc") %>%
  rename_at(vars(matches(paste0("logw_",progeny2))), ~ "logw") %>%
  rename(uc_extreme=ucextreme) %>%
  arrange_at(colonne, desc)


liste_parents <- crosses %>% dplyr::select(P1, P2) %>%
  unlist() %>% unique() %>% as.vector() 


liste_parents_kept <- liste_parents[1:min(min(c(Pmax+factor), Pmax2 +factor), length(liste_parents))]

crosses_filtered <- crosses %>% filter(P1 %in% liste_parents_kept | P2 %in% liste_parents_kept) %>%  #filter 1
  arrange_at(colonne, desc) %>%
  group_by(P1) %>%
  mutate(nP1=1:n()) %>%
  ungroup() %>% 
  group_by(P2) %>% 
  mutate(nP2=1:n()) %>%
  ungroup() %>%
  #filter(nP1 <= (Cmax +factor) & nP2 <= (Cmax + factor)) %>%  #filter 2
  arrange(P1, P2) %>%
  arrange_at(colonne, desc) %>%
  #dplyr::select(P1, P2, type, sim, qtls, h, r, population, one_of(colonne)) %>%
  dplyr::select(P1, P2, gebv, sd, logw, uc, uc_extreme) %>%
  as.data.frame()

} else {
  
  crosses <- crosses %>%  arrange(P1, P2) %>% 
    rename_at(vars(matches(paste0("sd_",progeny2))), ~ "sd") %>%
    rename_at(vars(matches(paste0("uc_extreme_",progeny2))), ~ "ucextreme") %>%
    rename_at(vars(matches(paste0("uc_",progeny2))), ~ "uc") %>%
    rename_at(vars(matches(paste0("logw_",progeny2))), ~ "logw") %>%
    rename(uc_extreme=ucextreme) %>%
    arrange_at(colonne)
    
  
  
  liste_parents <- crosses %>% dplyr::select(P1, P2) %>%
    unlist() %>% unique() %>% as.vector() 
  
  
  liste_parents_kept <- liste_parents[1:min(min(c(Pmax+factor), Pmax2 +factor), length(liste_parents))]
  
  crosses_filtered <- crosses %>% filter(P1 %in% liste_parents_kept | P2 %in% liste_parents_kept) %>%  #filter 1
    arrange_at(colonne) %>%
    group_by(P1) %>%
    mutate(nP1=1:n()) %>%
    ungroup() %>% 
    group_by(P2) %>% 
    mutate(nP2=1:n()) %>%
    ungroup() %>%
    #filter(nP1 <= (Cmax +factor) & nP2 <= (Cmax + factor)) %>%  #filter 2
    arrange(P1, P2) %>%
    arrange_at(colonne) %>%
    #dplyr::select(P1, P2, type, sim, qtls, h, r, population, one_of(colonne)) %>%
    dplyr::select(P1, P2, gebv, sd, logw, uc, uc_extreme) %>%
    
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



if (colonnei =="embv" | colonnei == "topq"){
  
  
  crosses_filtered <- crosses_filtered %>% dplyr::select(P1, P2) %>%
    inner_join(crosses, by=c("P1","P2")) %>%
    dplyr::select(P1, P2, gebv, sd, logw, uc, uc_extreme) %>%
    arrange(P1, P2)
  
}





cat("\n\n OUTPUT : crosses filtered \n\n")
head(crosses_filtered)
tail(crosses_filtered)
dim(crosses_filtered)

write.table(crosses_filtered, titre_crosses_filtered, col.names=T, row.names=F, dec=".", sep="\t", quote=F)


sessionInfo()