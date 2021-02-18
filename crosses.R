

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



titre_variance_crosses <- variables[1]
titre_lines <- variables[2]
titre_selection_intensity <- variables[3]
titre_function_calcul_index_variance_crosses <- variables[4]
selection_treshold <- as.numeric(variables[5])
selection_rate <- as.numeric(variables[6])
titre_crosses <- variables[7]


# titre_variance_crosses <-  "/work2/genphyse/dynagen/adanguy/croisements/150221/value_crosses/variance_crosses.txt"
# titre_lines <-"/work2/genphyse/dynagen/adanguy/croisements/150221/prepare/lines.txt"                 
# titre_selection_intensity <- "/work2/genphyse/dynagen/adanguy/croisements/150221/prepare/selection_intensity.txt"   
# titre_function_calcul_index_variance_crosses <-  "/work/adanguy/these/croisements/scripts/calcul_index_variance_crosses.R"              
# selection_treshold <-  8.0307627                                                                       
# selection_rate <- 0.07                                                                                
# titre_crosses <-"/work2/genphyse/dynagen/adanguy/croisements/150221/value_crosses/crosses.txt"



cat("\n\n INPUT : variance crosses \n\n")
variance_crosses <- fread(titre_variance_crosses)
head(variance_crosses)
dim(variance_crosses)


cat("\n\n INPUT : info lines \n\n")
lines <- fread(titre_lines)
head(lines)
dim(lines)

cat("\n\n INPUT : selection intensity table \n\n")
selection_intensity <- fread(titre_selection_intensity)
head(selection_intensity)
dim(selection_intensity)

source(titre_function_calcul_index_variance_crosses)

selection_intensity2=selection_intensity %>%
  filter(qij==!!selection_rate) %>%
  dplyr::select(int_qij) %>% 
  unlist() %>% as.vector()

lines2 <- lines %>% filter(used_as_parent==T) %>% arrange(line2) 
nind <- nrow(lines2)


variance_crosses2 <- variance_crosses %>% group_by(P1, P2) %>%
  summarise(sd_WE_Qsall=sqrt(sum(sd_WE)),
            sd_EE=sqrt(sum(sd_EE)),
            sd_WA=sqrt(sum(sd_WA)),
            sd_EA=sqrt(sum(sd_EA)),
            sd_CsRe=sqrt(sum(sd_CsRe))) %>%
  ungroup()

maxi <- nrow(variance_crosses2)
lines_to_keep <- calcul1(nind)


# mean of progeny GEBV
u <- matrix(outer(lines2$gebv, lines2$gebv, "+")/2, ncol=1)
u <- u[lines_to_keep]
rm(lines, lines2, lines_to_keep)


markers %>% group_by(chr) %>%
  summarise(dplyr::across(starts_with("dcum")), mean)


iris %>%
  group_by(Species) %>%
  summarise_at(vars(starts_with("Sepal")), mean)


# output
tab <- cbind(variance_crosses2, data.frame(u=u))%>%
  as.data.frame() %>%
  mutate(uc_WE=u+selection_intensity2*sd_WE) %>%
  mutate(uc_EE=u+selection_intensity2*sd_EE) %>%
  mutate(uc_WA=u+selection_intensity2*sd_WA) %>%
  mutate(uc_EA=u+selection_intensity2*sd_EA) %>%
  mutate(uc_CsRe=u+selection_intensity2*sd_CsRe) %>%
  mutate(logw_WE=log10(pnorm(selection_treshold, u, sd_WE))) %>%
  mutate(logw_EE=log10(pnorm(selection_treshold, u, sd_EE))) %>%
  mutate(logw_WA=log10(pnorm(selection_treshold, u, sd_WA))) %>%
  mutate(logw_EA=log10(pnorm(selection_treshold, u, sd_EA))) %>%
  mutate(logw_CsRe=log10(pnorm(selection_treshold, u, sd_CsRe))) %>%
  mutate(random=1) %>%
  dplyr::select(P1, #1
                P2, #2
                random, #3
                u, #4
                sd_WE, #5
                sd_EE, #6
                sd_WA, #7
                sd_EA, #8
                sd_CsRe, #9
                uc_WE, #10
                uc_EE, #11
                uc_WA, #12
                uc_EA, #13
                uc_CsRe,  #14    
                logw_WE, #15
                logw_EE, #16
                logw_WA, #17
                logw_EA, #18
                logw_CsRe) %>% #19
  ungroup() 
rm(variance_crosses, u)





cat("\n\nOUTPUT : variance of crosses and other performances \n\n")
head(tab)
dim(tab)
write_delim(tab, titre_crosses, col_names = T, delim="\t", append = F, na="NA", quote_escape="none")




sessionInfo()
