



Sys.time()
cat("\n\ratio.R\n\n")
rm(list = ls())
graphics.off()
set.seed(1)
t1 <-Sys.time() 

suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(compiler))



variables <- commandArgs(trailingOnly=TRUE)
cat("\n\nVariables : \n")
print(variables)
cat("\n\n")



titre_criteria <- variables[1]
titre_output <- variables[2]
info <- variables[3]
titre_correlations_output <- variables[4]


#titre_criteria_estimated <-  "/work/adanguy/these/croisements/250222/results/criteria_sTRUE_iESTIMATED_q300rand_h0.4_gGBLUP_punselected_n1_mWE_CONSTRAINTS.txt" 


cat("\n\n INPUT : crosses \n\n ")
criteria <- fread(titre_criteria)
head(criteria)
tail(criteria)
dim(criteria)


cat("\n\n INPUT : mating plan \n\n ")
mating <- fread(titre_mating_plan_input)
head(mating)
tail(mating)
dim(mating)

ratio <- criteria  %>%
  group_by(simulation, genetic_map, population, population_ID, CONSTRAINTS, qtls, qtls_info, heritability, genomic, progeny) %>%
  summarise(var_sd=var(sd), var_PM=var(PM), ratio=var_sd/var(PM)) %>%
  mutate(info=!!info) %>%
  as.data.frame() %>%
  dplyr::select(-one_of("CONSTRAINTS", "genetic_map", "qtls", "progeny", "simulation", "genomic"))



criteria_list <- c("PM","PROBA", "UC1","UC2","UC3", "EMBV", "OHV", "sd")

order_criterion <- data.frame(criterion=criteria_list, ordre=1:length(criteria_list))

correlations <- criteria %>%
  dplyr::select(PM, UC1, sd, UC2, EMBV, OHV, PROBA) %>%
  rowwise() %>%
  mutate(PROBA=1 - 10^(PROBA)) %>%
  ungroup() %>%
   cor() %>%
  reshape2::melt() %>%
  rename(criterion1=Var1, criterion2=Var2, correlation=value) %>%
  inner_join(order_criterion, by=c("criterion1"="criterion"))%>%
  inner_join(order_criterion, by=c("criterion2"="criterion")) %>%
  rename(ordre1=ordre.x)%>%
  rename(ordre2=ordre.y) %>%
  mutate(criterionA=ifelse(ordre1 <= ordre2, as.character(criterion1), as.character(criterion2))) %>%
  mutate(criterionB=ifelse(ordre1 > ordre2, as.character(criterion1), as.character(criterion2))) %>%
  dplyr::select(-criterion1, -criterion2, -ordre1, -ordre2) %>%
  rename(criterion1=criterionA, criterion2=criterionB) %>%
  unique() %>%
  arrange(desc(criterion1), criterion2) %>%
  mutate(P1=criteria$P1[1], P2=criteria$P2[1]) %>%
  inner_join(criteria , by=c("P1","P2")) %>%
  dplyr::select(-one_of("UC1","UC2","OHV","PROBA","EMBV", "sd", "P1","P2", "PM"))  %>%
  dplyr::select(-one_of("CONSTRAINTS", "genetic_map", "qtls", "progeny", "simulation", "genomic"))


  

cat("\n\nOUTPUT : ratio \n\n")
head(ratio)
tail(ratio)
dim(ratio)
write_delim(ratio, titre_output, col_names = T, delim="\t", append = F, na="NA", quote_escape="none")



cat("\n\nOUTPUT : correlations \n\n")
head(correlations)
tail(correlations)
dim(correlations)
write_delim(correlations, titre_correlations_output, col_names = T, delim="\t", append = F, na="NA", quote_escape="none")



sessionInfo()
