

# Goal : Produce a standardized map for each population to compute variance-covariance matrix of progeny genotype
# Input : recombination profiles of several populations
# Output : standardized genetic map for each pop


Sys.time()
cat("\n\nsd_predictions.R\n\n")
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

titre_crosses <-variables[1]
nbcrosses <- as.numeric(variables[2])
nbprogeny <- as.numeric(variables[3])
titre_crosses_subset <- variables[4]



# titre_crosses <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/crosses.txt"
# titre_crosses_subset 
# nbcrosses <- 200
# nbprogeny=200






cat("\n\n INPUT : crosses \n\n")
crosses <- fread(titre_crosses) %>%as.data.frame()
head(crosses)


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


lines_u = choose_crosses(crosses=crosses, statistique="u", nb_choosen_crosses = floor(nbcrosses/4))
lines_sd = choose_crosses(crosses=crosses, statistique="sd_WE", nb_choosen_crosses = floor(nbcrosses/4))
lines_uc = choose_crosses(crosses=crosses, statistique="uc_WE", nb_choosen_crosses = floor(nbcrosses/4))
lines_logw = choose_crosses(crosses=crosses, statistique="logw_WE", nb_choosen_crosses = floor(nbcrosses/4))


lines <- c(lines_u, lines_sd, lines_uc, lines_logw)
lines <- sort(unique(lines))

while (length(lines) < nbcrosses){
  
  lines <- c(lines, sample(1:nrow(crosses), size = nbcrosses - length(lines), replace=F))
  lines <- sort(unique(lines))
}


crosses_subset <- crosses[lines, ] %>%
  mutate(nbprogeny=nbprogeny) %>%
  mutate(generation=1) %>%
  mutate(run=1) %>%
  dplyr::select(P1, P2, nbprogeny, generation, run) %>%
  arrange(P1, P2)


cat("\n\n OUTPUT : subset crosses \n\n")
head(crosses_subset)
write.table(crosses_subset, titre_crosses_subset, col.names = T, row.names = F, dec=".", sep="\t", quote=F)

sessionInfo()
