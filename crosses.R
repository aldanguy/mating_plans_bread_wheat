

# Goal : Produce a standardized map for each population to compute variance-covariance matrix of progeny genotype
# Input : recombination profiles of several populations
# Output : standardized genetic map for each pop



Sys.time()
cat("\n\ncrosses.R\n\n")
rm(list = ls())
graphics.off()
set.seed(1)

suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(compiler))
suppressPackageStartupMessages(library(readr))



variables <- commandArgs(trailingOnly=TRUE)
cat("\n\nVariables : \n")
print(variables)
cat("\n\n")



titre_variance_crosses_input <- variables[1]
titre_lines_parents_input <- variables[2]
titre_selection_intensity_input <- variables[3]
titre_best_order_statistic_input <- variables[4]
selection_treshold_PROBA <- as.numeric(variables[5])
within_family_selection_rate_UC1 <- as.numeric(variables[6])
within_family_selection_rate_UC2 <- as.numeric(variables[7])
Dmax_EMBV <- as.numeric(variables[8])
titre_function_calcul_index_variance_crosses <- variables[9]
titre_crosses_output <- variables[10]




#  
# titre_variance_crosses_input <-"/work2/genphyse/dynagen/adanguy/croisements/230821/value_crosses/variance_crosses/variance_crosses_simTRUE_300rand_h0.4_r5_unselected_ggblup_WE.txt"
# titre_lines_parents_input <- "/work2/genphyse/dynagen/adanguy/croisements/230821/value_crosses/lines/lines_gebv_unselected_simTRUE_300rand_h0.4_r5_ggblup.txt"                    
# titre_selection_intensity_input <- "/work2/genphyse/dynagen/adanguy/croisements/230821/prepare/selection_intensity.txt"                                                                 
# titre_function_calcul_index_variance_crosses <- "/work/adanguy/these/croisements/scripts/03_03_01_01_02_calcul_index_variance_crosses.R"                                                             
# selection_treshold <- 9.1623611                                                                                                                                    
# selection_rate <- 0.07                                                                                                                                              
# titre_crosses_output <- "/work2/genphyse/dynagen/adanguy/croisements/230821/value_crosses/crosses/crosses_simTRUE_300rand_h0.4_r5_unselected_ggblup_WE.txt"                  
#   type <-  "simTRUE_300rand_h0.4_r5"                                                                                                                            
#   population_variance <- "WE"                                                                                                                                                 
#   selected <-  "unselected"                                                                                                                                         
#   g <-  "gblup"



cat("\n\n INPUT : variance crosses \n\n")
variance_crosses <- fread(titre_variance_crosses_input) 
head(variance_crosses)
tail(variance_crosses)
dim(variance_crosses)

cat("\n\n INPUT : lines info \n\n")
lines <- fread(titre_lines_parents_input)
head(lines)
tail(lines)
dim(lines)




cat("\n\n INPUT : selection intensity table \n\n")
selection_intensity <- fread(titre_selection_intensity_input)
head(selection_intensity)
tail(selection_intensity)
dim(selection_intensity)

cat("\n\n INPUT : best order statistic input \n\n")
best_order_stat <- fread(titre_best_order_statistic_input)
head(best_order_stat)
tail(best_order_stat)
dim(best_order_stat)

source(titre_function_calcul_index_variance_crosses)


selection_intensity_UC1=selection_intensity %>%
  filter(qij==!!within_family_selection_rate_UC1) %>%
  dplyr::select(int_qij) %>% 
  unlist() %>% as.vector()

selection_intensity_UC2=selection_intensity %>%
  filter(qij==!!within_family_selection_rate_UC2) %>%
  dplyr::select(int_qij) %>% 
  unlist() %>% as.vector()

selection_intensity_EMBV=best_order_stat %>%
  filter(dij==!!Dmax_EMBV) %>%
  dplyr::select(int_best_dij) %>% 
  unlist() %>% as.vector()

lines2 <- lines  %>% arrange(ID) %>% dplyr::select(ID, value)


crosses <- variance_crosses  %>%
  group_by(P1, P2,  genetic_map, simulation, qtls, qtls_info, heritability, genomic, population, progeny, population_ID) %>%
  summarise(sd=sqrt(sum(variance)))%>%
  ungroup()%>%
  right_join(lines2, by=c("P1"="ID")) %>%
  inner_join(lines2, by=c("P2"="ID"))%>%
  rowwise() %>%
  mutate(PM=(value.x+value.y)/2) %>%
  mutate(PROBA=log10(pnorm(selection_treshold_PROBA, PM, sd))) %>%
  mutate(UC1=PM + selection_intensity_UC1*sd) %>%
  mutate(UC2=PM + selection_intensity_UC2*sd) %>% 
  mutate(EMBV=PM + selection_intensity_EMBV*sd) %>%
  arrange(P1, P2) %>%
  as.data.frame() %>%
  mutate(CONSTRAINTS="NO_CONSTRAINTS") %>%
  dplyr::select(P1, P2, genetic_map, simulation, qtls, qtls_info, heritability, genomic, population, progeny, population_ID, CONSTRAINTS, sd, PM, UC1, UC2, PROBA, EMBV)









cat("\n\nOUTPUT : variance of crosses and other performances \n\n")
head(crosses)
tail(crosses)
dim(crosses)
write_delim(crosses, titre_crosses_output, col_names = T, delim="\t", append = F, na="NA", quote_escape="none")




sessionInfo()
