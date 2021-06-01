

# Goal : Produce a standardized map for each population to compute variance-covariance matrix of progeny genotype
# Input : recombination profiles of several populations
# Output : standardized genetic map for each pop


Sys.time()
cat("\n\nsubset_crosses_sd_predictions.R\n\n")
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

titre_crosses_input <-variables[1]
nbcrosses <- as.numeric(variables[2])
nbprogeny <- as.numeric(variables[3])
titre_crosses_subset_output <- variables[4]
progeny <- variables[5]



# titre_crosses_input <- "/work2/genphyse/dynagen/adanguy/croisements/050321/value_crosses/crosses/crosses_g1_simTRUE_20cm_r1_WE.txt"
# nbcrosses <- 50                                                                                                      
# nbprogeny <- 50                                                                                                        
# titre_crosses_subset_output <-  "/work2/genphyse/dynagen/adanguy/croisements/050321/sd_predictions/subset_crosses_g1_simTRUE_20cm_r1_WE.txt"
# 
# 
# 



progeny2=as.vector(unlist(strsplit(split="F", progeny)))[1]



cat("\n\n INPUT : crosses \n\n")
crosses <- fread(titre_crosses_input) 
head(crosses)
tail(crosses)
dim(crosses)


crosses <- crosses%>% 
  rename_at(vars(matches(paste0("sd_",progeny2))), ~ "sd") %>%
  rename_at(vars(matches(paste0("uc_extreme_",progeny2))), ~ "ucextreme") %>%
  rename_at(vars(matches(paste0("uc_",progeny2))), ~ "uc") %>%
  rename_at(vars(matches(paste0("logw_",progeny2))), ~ "logw") %>%
  rename(uc_extreme=ucextreme)






choose_crosses <- function(crosses, statistique, nb_choosen_crosses){
  
  
  
  born_inf <- min(crosses %>% dplyr::select(one_of(statistique)))
  born_sup <- max(crosses %>% dplyr::select(one_of(statistique)))
  
  step=(born_sup - born_inf)/nb_choosen_crosses
  echant <- seq(born_inf, born_sup, step)
  
  vecteur= crosses %>% dplyr::select(one_of(statistique)) %>% unlist() %>% as.vector()
  lines <- as.numeric()
  k=0
  for (i in echant[-1]){
    
    temp <- which.min(abs(i - vecteur))
    after <- temp+1
    previous <- temp-1
    
    
    if (temp %in% lines){
    
    
      temp <- which.min(abs(i - vecteur[-lines]))
      value <- vecteur[-lines][temp]
      temp <- max(sort(which(vecteur==value)))
      
    }
  
    lines <- c(lines, temp)
    #print(crosses[temp,statistique])

}

  return(sort(lines))
  
}


lines_gebv = choose_crosses(crosses=crosses, statistique="gebv", nb_choosen_crosses = floor(nbcrosses/5))
lines_sd = choose_crosses(crosses=crosses, statistique="sd", nb_choosen_crosses = floor(nbcrosses/5))
lines_uc = choose_crosses(crosses=crosses, statistique="uc", nb_choosen_crosses = floor(nbcrosses/5))
lines_logw = choose_crosses(crosses=crosses, statistique="logw", nb_choosen_crosses = floor(nbcrosses/5))
lines_uc_extreme = choose_crosses(crosses=crosses, statistique="uc_extreme", nb_choosen_crosses = floor(nbcrosses/5))


lines <- c(lines_gebv, lines_sd, lines_uc, lines_logw, lines_uc_extreme)
lines <- sort(unique(lines))

while (length(lines) < nbcrosses){
  
  lines <- c(lines, sample(1:nrow(crosses), size = nbcrosses - length(lines), replace=F))
  lines <- sort(unique(lines))
}


crosses_subset <- crosses[lines, ] %>%
  mutate(nbprogeny=nbprogeny) %>%
  dplyr::select(P1, P2, nbprogeny) %>%
  arrange(P1, P2) %>%
  as.data.frame()


cat("\n\n OUTPUT : subset crosses \n\n")
head(crosses_subset)
tail(crosses_subset)
dim(crosses_subset)
write.table(crosses_subset, titre_crosses_subset_output, col.names = T, row.names = F, dec=".", sep="\t", quote=F)

sessionInfo()
