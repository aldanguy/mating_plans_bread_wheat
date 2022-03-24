


# Goal : compute variance of cross, probability to produce a progeny whose GEBV would be lower than a treshold lambda, UC for a specific selection rate q
# Input : marker effects, variance covariance matrix of progeny genotypes, genotyping matrix of parental line, gebv of parental lines, selection intensity table and value of best parental line
# Output : tab which names of parents, and 4 indices : expected GEBV of progeny (u), variance of progeny (sd), probability to be lower than a treshold lambda (log_w) and UC



# warning : GEBV and geno has to have the same order for LINES
# warning : effects and geno has to have the same order for SNP


Sys.time()
cat("\n\naccuracy_sd\n\n")
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



titre_criteria_estimated1 <- variables[1]
titre_criteria_estimated2 <-  variables[2]
titre_output <- variables[3]

# titre_criteria_estimated <-  "/work/adanguy/these/croisements/250222/results/criteria_sTRUE_iESTIMATED_q300rand_h0.4_gGBLUP_punselected_n1_mWE_CONSTRAINTS.txt" 
# titre_criteria_true <-  "/work/adanguy/these/croisements/250222/results/criteria_sTRUE_iTRUE_q300rand_hNA_gNA_punselected_n1_mWE_NO_CONSTRAINTS_no_filter.txt"


cat("\n\n INPUT : estimated \n\n ")
estimated1 <- fread(titre_criteria_estimated1)
head(estimated1)
tail(estimated1)
dim(estimated1)

cat("\n\n INPUT : estimated \n\n ")
estimated2 <- fread(titre_criteria_estimated2)
head(estimated2)
tail(estimated2)
dim(estimated2)

output <- estimated1  %>%
  inner_join(estimated2 %>% dplyr::select(P1, P2), by=c("P1", "P2")) %>%
  arrange(P1, P2) %>%
  as.data.frame()

cat("\n\nOUTPUT : filter \n\n")
head(output)
dim(output)
write_delim(output, titre_output, col_names = T, delim="\t", append = F, na="NA", quote_escape="none")




sessionInfo()
