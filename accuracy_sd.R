


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
suppressPackageStartupMessages(library(reshape2))



variables <- commandArgs(trailingOnly=TRUE)
cat("\n\nVariables : \n")
print(variables)
cat("\n\n")



titre_criteria_estimated <- variables[1]
titre_criteria_true <-  variables[2]
titre_output <- variables[3]
info <- variables[4]

# titre_criteria_estimated <-  "/work/adanguy/these/croisements/250222/results/criteria_sTRUE_iESTIMATED_q300rand_h0.4_gGBLUP_punselected_n1_mWE_CONSTRAINTS.txt" 
# titre_criteria_true <-  "/work/adanguy/these/croisements/250222/results/criteria_sTRUE_iTRUE_q300rand_hNA_gNA_punselected_n1_mWE_NO_CONSTRAINTS_no_filter.txt"


cat("\n\n INPUT : estimated \n\n ")
estimated <- fread(titre_criteria_estimated)
head(estimated)
tail(estimated)
dim(estimated)

cat("\n\n INPUT : estimated \n\n ")
true <- fread(titre_criteria_true)
head(true)
tail(true)
dim(true)

ratio <- estimated  %>%
  dplyr::select(-one_of("UC1","UC2","OHV","PROBA","EMBV")) %>%
  rename(sd_esti=sd, PM_esti=PM) %>%
  inner_join(true %>%
              dplyr::select(P1, P2, sd, PM) %>%
              rename(sd_true=sd, PM_true=PM),
            by=c("P1","P2")) %>%
  mutate(bias_sd=(sd_esti-sd_true)/sd_true,
         bias_PM=(PM_esti-PM_true)/PM_true) %>%
  group_by(simulation, genetic_map, population, population_ID, CONSTRAINTS, qtls, qtls_info, heritability, genomic, progeny) %>%
  summarise(bias_sd=mean(bias_sd), 
            bias_PM=mean(bias_PM), 
            cor_sd=cor(sd_esti, sd_true),
            cor_PM=cor(PM_esti, PM_true),
            var_sd_esti=var(sd_esti), 
            var_sd_true=var(sd_true),
            var_PM_esti=var(PM_esti),
            var_PM_true=var(PM_true),
            ratio_var_sd_esti=var_sd_esti/var_sd_true, 
            ratio_var_PM_esti=var_PM_esti/var_PM_true) %>%
  mutate(info=!!info) %>%
  as.data.frame() %>%
  dplyr::select(-one_of("CONSTRAINTS", "genetic_map", "qtls", "progeny", "simulation", "genomic"))








cat("\n\nOUTPUT : ratio \n\n")
head(ratio)
dim(ratio)
write_delim(ratio, titre_output, col_names = T, delim="\t", append = F, na="NA", quote_escape="none")




sessionInfo()
