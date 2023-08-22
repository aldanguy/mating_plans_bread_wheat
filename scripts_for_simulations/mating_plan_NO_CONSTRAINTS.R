


Sys.time()
cat("\n\noptimization_NO_CONSTRAINTS\n\n")
rm(list = ls())
graphics.off()
set.seed(1)

suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(compiler))
suppressPackageStartupMessages(library(igraph))
suppressPackageStartupMessages(library(ggpubr))



variables <- commandArgs(trailingOnly=TRUE)
cat("\n\nVariables : \n")
print(variables)
cat("\n\n")



titre_criteria_input <- variables[1]
criterion <- variables[2]
D <- as.numeric(variables[3])
Dmax <- as.numeric(variables[4])
titre_mating_plan_output <- variables[5]


# titre_criteria_input <- "/work2/genphyse/dynagen/adanguy/croisements/250222/article/criteria/criteria_sTRUE_iESTIMATED_q300rand_h0.4_gGBLUP_punselected_n3_mWE_NO_CONSTRAINTS.txt"           
# criterion <-  "UC1"                                                                                                                                                                
# D <- 3300                                                                                                                                                              
# Dmax <- 60                                                                                                                                                           
# titre_mating_plan_output <-"/work2/genphyse/dynagen/adanguy/croisements/250222/article/optimization/mating_plan_sTRUE_iESTIMATED_q300rand_h0.4_gGBLUP_punselected_n3_mWE_NO_CONSTRAINTS_UC1.txt"





# titre_ldak <- "/work2/genphyse/dynagen/adanguy/croisements/190821/ibs/ibs/ibs_ldak_unselected.txt"                                  
# titre_desirable_crosses_output <- "/work2/genphyse/dynagen/adanguy/croisements/190821/value_crosses/desirables_crosses/desirable_crosses_unselected.txt"


cat("\n\n INPUT criteria \n\n")
criteria <- fread(titre_criteria_input)
head(criteria)
tail(criteria)
dim(criteria)


nbcrosses <- floor(D/Dmax)

if (criterion != "PROBA"){

mating_plan <- criteria %>%
  rename_at(vars(one_of(criterion)), ~ "criterion")%>%
  arrange(desc(criterion)) %>%
  slice(1:nbcrosses) %>%
  mutate(nbprogeny=!!Dmax) %>%
  mutate(criterion=!!criterion) %>%
  dplyr::select(-one_of("PM","sd", "OHV","UC1","UC2","EMBV", "PROBA")) %>%
  arrange(P1, P2)
  

} else {
  
  mating_plan <- criteria %>%
    rename_at(vars(one_of(criterion)), ~ "criterion")%>%
    arrange(criterion) %>%
    slice(1:nbcrosses) %>%
    mutate(nbprogeny=!!Dmax) %>%
    mutate(criterion=!!criterion) %>%
    dplyr::select(-one_of("PM","sd", "OHV","UC1","UC2","EMBV", "PROBA")) %>%
    arrange(P1, P2)
  
  
  
}


cat("\n\n mating plan\n\n")
head(mating_plan)
tail(mating_plan)
dim(mating_plan)

write.table(mating_plan, titre_mating_plan_output, col.names = T, dec=".", sep=" ", quote=F, row.names = F)

sessionInfo()
