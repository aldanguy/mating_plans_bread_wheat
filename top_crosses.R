



Sys.time()
cat("\n\ntop_crosses.R\n\n")
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
D <- as.numeric(variables[2])
Dmax <- as.numeric(variables[3])
colonne <- variables[4]
type <- variables[5]
population_variance <- variables[6]
programme <- variables[7]
titre_best_crosses_output <- variables[8]
progeny <- variables[9]
titre_best_order_statistic <- variables[10]



# titre_crosses <-  "/work2/genphyse/dynagen/adanguy/croisements/200421/value_crosses/crosses/crosses_simTRUE_300rand_r1_WE.txt"                 
# D <- 3300                                                                                                                      
# Dmax <- 60                                                                                                                        
# colonne <-"embv"                                                                                                                       
# type <-  "simTRUE_300rand_r1"                                                                                                         
# population_variance <-  "WE"                                                                                                                         
# programme <-"real_top"                                                                                                                   
# titre_best_crosses_output <-  "/work2/genphyse/dynagen/adanguy/croisements/200421/best_crosses/best_crosses_simTRUE_300rand_r1_WE_embv_real_top_RILsF5.txt"
# progeny <- "RILsF5"                                                                                                                     
# titre_best_order_statistic <-  "/work2/genphyse/dynagen/adanguy/croisements/200421/prepare/expected_best_order_statistic.txt"                               
# 
# 


critere <- colonne


cat("\n\n INPUT : crosses \n\n")
crosses <- fread(titre_crosses)
head(crosses)
tail(crosses)
dim(crosses)

cat("\n\n INPUT : best order stat \n\n")
best_order_stat <- fread(titre_best_order_statistic)
head(best_order_stat)
tail(best_order_stat)
dim(best_order_stat)

nb_crosses <- floor(D/Dmax)



selfing=as.numeric(as.vector(unlist(strsplit(split="F", progeny)))[2])
progeny2=as.vector(unlist(strsplit(split="F", progeny)))[1]



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


if (colonne !="logw" & colonne !="embv"){
  

  best_crosses <- crosses %>% 
    rename_at(vars(matches(paste0("sd_",progeny2))), ~ "sd") %>%
    rename_at(vars(matches(paste0("uc_extreme_",progeny2))), ~ "ucextreme") %>%
    rename_at(vars(matches(paste0("uc_",progeny2))), ~ "uc") %>%
    rename_at(vars(matches(paste0("logw_",progeny2))), ~ "logw") %>%
    rename(uc_extreme=ucextreme) %>%
  arrange_at(colonne, desc) %>%
  slice(1:nb_crosses) %>%
    mutate(nbprogeny=Dmax)
  
  
  if (floor(D/Dmax)!=D/Dmax){
    
    best_crosses <- rbind(best_crosses, 
                          crosses %>% 
      rename_at(vars(matches(paste0("sd_",progeny2))), ~ "sd") %>%
      rename_at(vars(matches(paste0("uc_extreme_",progeny2))), ~ "ucextreme") %>%
      rename_at(vars(matches(paste0("uc_",progeny2))), ~ "uc") %>%
      rename_at(vars(matches(paste0("logw_",progeny2))), ~ "logw") %>%
      rename(uc_extreme=ucextreme) %>%
      arrange_at(colonne, desc) %>%
      slice(nb_crosses+1) %>%
      mutate(nbprogeny=D-sum(best_crosses$nbprogeny)))
      
    
}
  
  print(best_crosses)
  
  
  best_crosses <- best_crosses%>%
  mutate(type=!!etat) %>%
  mutate(sim=!!sim) %>%
  mutate(qtls=!!qtls) %>%
  mutate(h=!!h) %>%
  mutate(r=!!r) %>%
  mutate(population_variance=!!population_variance) %>%
  mutate(critere=!!critere) %>%
  mutate(programme=!!programme)%>%
    mutate(progeny=!!progeny) %>%
  dplyr::select(P1, P2, type, sim, qtls, h, r, population_variance, critere, programme, progeny, nbprogeny) 

} else if (colonne=="logw") {
  
  
  best_crosses <- crosses %>% 
    rename_at(vars(matches(paste0("sd_",progeny2))), ~ "sd") %>%
    rename_at(vars(matches(paste0("uc_extreme_",progeny2))), ~ "ucextreme") %>%
    rename_at(vars(matches(paste0("uc_",progeny2))), ~ "uc") %>%
    rename_at(vars(matches(paste0("logw_",progeny2))), ~ "logw") %>%
    rename(uc_extreme=ucextreme) %>%
    arrange_at(colonne) %>%
    slice(1:nb_crosses) %>%
    mutate(nbprogeny=Dmax)
  
  
  if (floor(D/Dmax)!=D/Dmax){
    
    best_crosses <- rbind(best_crosses, 
                          crosses %>% 
                            rename_at(vars(matches(paste0("sd_",progeny2))), ~ "sd") %>%
                            rename_at(vars(matches(paste0("uc_extreme_",progeny2))), ~ "ucextreme") %>%
                            rename_at(vars(matches(paste0("uc_",progeny2))), ~ "uc") %>%
                            rename_at(vars(matches(paste0("logw_",progeny2))), ~ "logw") %>%
                            rename(uc_extreme=ucextreme) %>%
                            arrange_at(colonne) %>%
                            slice(nb_crosses+1) %>%
                            mutate(nbprogeny=D-sum(best_crosses$nbprogeny)))
    
    
  }
  
  
  print(best_crosses)
  
  best_crosses <- best_crosses%>%
    mutate(type=!!etat) %>%
    mutate(sim=!!sim) %>%
    mutate(qtls=!!qtls) %>%
    mutate(h=!!h) %>%
    mutate(r=!!r) %>%
    mutate(population_variance=!!population_variance) %>%
    mutate(critere=!!critere) %>%
    mutate(programme=!!programme)%>%
    mutate(progeny=!!progeny) %>%
    dplyr::select(P1, P2, type, sim, qtls, h, r, population_variance, critere, programme, progeny, nbprogeny) 
} else if (colonne=="embv") {
  
  best_order_stat <- best_order_stat %>% filter(dij==!!Dmax) %>%
    dplyr::select(int_best_dij) %>%
    unlist() %>%
    as.vector()
  
  best_crosses <- crosses %>% 
    rename_at(vars(matches(paste0("sd_",progeny2))), ~ "sd") %>%
    mutate(embv=gebv+!!best_order_stat*sd) %>%
    arrange(desc(embv))%>%
    slice(1:nb_crosses) %>%
    mutate(nbprogeny=Dmax)
  
  
  if (floor(D/Dmax)!=D/Dmax){
    
    best_crosses <- rbind(best_crosses, 
                          crosses %>% 
                            rename_at(vars(matches(paste0("sd_",progeny2))), ~ "sd") %>%
                            mutate(embv=gebv+!!best_order_stat*sd) %>%
                            arrange(desc(embv))%>%
                            slice(nb_crosses+1) %>%
                            mutate(nbprogeny=D-sum(best_crosses$nbprogeny)))
    
    
  }
  
  
  print(best_crosses)
  
  
  best_crosses <- best_crosses%>%
    mutate(type=!!etat) %>%
    mutate(sim=!!sim) %>%
    mutate(qtls=!!qtls) %>%
    mutate(h=!!h) %>%
    mutate(r=!!r) %>%
    mutate(population_variance=!!population_variance) %>%
    mutate(critere=!!critere) %>%
    mutate(programme=!!programme)%>%
    mutate(progeny=!!progeny) %>%
    dplyr::select(P1, P2, type, sim, qtls, h, r, population_variance, critere, programme, progeny, nbprogeny)
  
}





cat("\n\n OUTPUT : best crosses \n\n")
head(best_crosses)
tail(best_crosses)
dim(best_crosses)

write.table(best_crosses, titre_best_crosses_output, col.names=T, row.names=F, dec=".", sep="\t", quote=F)


sessionInfo()