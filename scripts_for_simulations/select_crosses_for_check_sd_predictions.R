


Sys.time()
cat("\n\nselect_crosses_for_sd_predictions\n\n")
rm(list = ls())
graphics.off()
set.seed(1)
t1 <- Sys.time()

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
titre_mating_plan_output <- variables[4]







cat("\n\n INPUT : crosses \n\n")
crosses <- fread(titre_crosses_input) 
head(crosses)
tail(crosses)
dim(crosses)


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


crosses_PM = choose_crosses(crosses=crosses, statistique="PM", nb_choosen_crosses = floor(nbcrosses/6))
crosses_sd = choose_crosses(crosses=crosses, statistique="sd", nb_choosen_crosses = floor(nbcrosses/6))
crosses_UC1 = choose_crosses(crosses=crosses, statistique="UC1", nb_choosen_crosses = floor(nbcrosses/6))
crosses_PROBA = choose_crosses(crosses=crosses, statistique="PROBA", nb_choosen_crosses = floor(nbcrosses/6))
crosses_UC2 = choose_crosses(crosses=crosses, statistique="UC2", nb_choosen_crosses = floor(nbcrosses/6))
crosses_OHV = choose_crosses(crosses=crosses, statistique="OHV", nb_choosen_crosses = floor(nbcrosses/6))


crosses_selected <- c(crosses_PM, crosses_sd, crosses_UC1, crosses_PROBA, crosses_UC2, crosses_OHV)
crosses_selected <- sort(unique(crosses_selected))

while (length(crosses_selected) < nbcrosses){
  
  crosses_selected <- c(crosses_selected, sample(1:nrow(crosses), size = nbcrosses - length(crosses_selected), replace=F))
  crosses_selected <- sort(unique(crosses_selected))
}


crosses_subset <- crosses[crosses_selected, ] %>%
  mutate(nbprogeny=!!nbprogeny) %>%
  mutate(criterion="sd_prediction") %>%
  dplyr::select(P1, P2, nbprogeny, everything()) %>%
  arrange(P1, P2) %>%
  as.data.frame()


cat("\n\n OUTPUT : subset crosses \n\n")
head(crosses_subset)
tail(crosses_subset)
dim(crosses_subset)
write.table(crosses_subset, titre_mating_plan_output, col.names = T, row.names = F, dec=".", sep="\t", quote=F)

sessionInfo()
