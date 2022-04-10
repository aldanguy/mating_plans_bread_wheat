


# Goal : compute variance of cross, probability to produce a progeny whose GEBV would be lower than a treshold lambda, UC for a specific selection rate q
# Input : marker effects, variance covariance matrix of progeny genotypes, genotyping matrix of parental line, gebv of parental lines, selection intensity table and value of best parental line
# Output : tab which names of parents, and 4 indices : expected GEBV of progeny (u), variance of progeny (sd), probability to be lower than a treshold lambda (log_w) and UC



# warning : GEBV and geno has to have the same order for LINES
# warning : effects and geno has to have the same order for SNP


Sys.time()
cat("\n\ncorrelations\n\n")
rm(list = ls())
graphics.off()
set.seed(1)
t1 <-Sys.time() 

suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(compiler))
suppressPackageStartupMessages(library(reshape2))



variables <- commandArgs(trailingOnly=TRUE)
cat("\n\nVariables : \n")
print(variables)
cat("\n\n")



titre_criteria <- variables[1]
titre_output <- variables[2]

#titre_criteria <-  "/work2/genphyse/dynagen/adanguy/croisements/250222/article/criteria/criteria_sTRUE_iESTIMATED_q300rand_h0.4_gGBLUP_pselected_n10_mWE_CONSTRAINTS.txt"


cat("\n\n INPUT : criteria \n\n ")
criteria <- fread(titre_criteria)
head(criteria)
tail(criteria)
dim(criteria)

order_criterion <- data.frame(criterion=c("PM","PROBA", "UC1","UC2","UC3", "EMBV", "OHV", "sd"),
                              ordre=1:8)

correlations <- criteria  %>%
  dplyr::select(one_of("UC1","UC2","OHV","PROBA","EMBV", "sd", "PM")) %>%
  cor() %>%
  melt() %>%
  rename(criterion1=Var1, criterion2=Var2) %>%
  inner_join(order_criterion, by=c("criterion1"="criterion")) %>%
  dplyr::rename(ordre1=ordre)%>%
  inner_join(order_criterion, by=c("criterion2"="criterion")) %>%
  dplyr::rename(ordre2=ordre) %>%
  mutate(criterionA=ifelse(ordre1 <= ordre2, as.character(criterion1), as.character(criterion2)))%>%
  mutate(criterionB=ifelse(ordre1 > ordre2, as.character(criterion1), as.character(criterion2))) %>%
  dplyr::select(criterionA, criterionB, value) %>%
  dplyr::rename(criterion1=criterionA, criterion2=criterionB) %>%
  unique() %>%
  mutate(P1=criteria$P1[1], P2=criteria$P2[1]) %>%
    inner_join(criteria , by=c("P1","P2")) %>%
  arrange(criterion1, criterion2) %>%
  as.data.frame() %>%
  dplyr::select(-one_of("P1", "P2", "genetic_map", "qtls", "progeny", "simulation", "genomic", order_criterion$criterion))








cat("\n\nOUTPUT : correlations \n\n")
head(correlations)
tail(correlations)
dim(correlations)
write_delim(correlations, titre_output, col_names = T, delim="\t", append = F, na="NA", quote_escape="none")




sessionInfo()
