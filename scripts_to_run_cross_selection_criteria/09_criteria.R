

# Goal : compute usefulness criteria for each cross


Sys.time()
cat("\n\n09_criteria.R\n\n")
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



titre_variance_progeny_input <- variables[1]
titre_breeding_values_input <- variables[2]
titre_selection_intensity_table_input <- variables[3]
within_family_selection_rate <- as.numeric(variables[4])
within_family_selection_rate_extreme <- as.numeric(variables[5])
within_family_selection_treshold <- as.numeric(variables[6])
titre_criteria_output <- variables[7]
titre_function_calcul_index_variance_crosses <- variables[8]


cat("\n\n INPUT : variance progeny \n\n")
v <- fread(titre_variance_progeny_input)
head(v)
tail(v)
dim(v)


cat("\n\n INPUT : breeding values \n\n")
bv <-  fread(titre_breeding_values_input)
head(bv)
tail(bv)
dim(bv)


cat("\n\n INPUT : selection intensity table \n\n")
si <- fread(titre_selection_intensity_table_input)
head(si)
tail(si)
dim(si)

source(titre_function_calcul_index_variance_crosses)


si2=si %>%
  filter(qij==!!within_family_selection_rate) %>%
  dplyr::select(int_qij) %>% 
  unlist() %>% as.vector()

si3=si %>%
  filter(qij==!!within_family_selection_rate_extreme) %>%
  dplyr::select(int_qij) %>% 
  unlist() %>% as.vector()


# nind <- nrow(bv)


#lines_to_keep <- calcul1(nind)


# mean of progeny GEBV
# u <- matrix(outer(bv$value, bv$value, "+")/2, ncol=1)
# u <- u[lines_to_keep]
# rm(bv, lines_to_keep)



vf <- v%>%
  right_join(bv, by=c("P1"="ID")) %>%
  right_join(bv, by=c("P2"="ID"))%>%
  rowwise() %>%
  mutate(expected_progeny=(value.x+value.y)/2)%>%
  mutate(proba_lower_treshold=log10(pnorm(within_family_selection_treshold, expected_progeny, sd_progeny))) %>%
  mutate(uc=expected_progeny+si2*sd_progeny) %>%
  mutate(uc_extreme=expected_progeny + si3*sd_progeny) %>% 
  arrange(P1, P2) %>%
  dplyr::select(P1, P2, 
                sd_progeny,
                expected_progeny,
                proba_lower_treshold, 
                uc, 
                uc_extreme) %>%
  ungroup() %>%
  as.data.frame() %>%
  na.omit()




rm(v, u)





cat("\n\nOUTPUT : criteria \n\n")
head(vf)
tail(vf)
dim(vf)
write_delim(vf, titre_criteria_output, col_names = T, delim="\t", append = F, na="NA", quote_escape="none")




sessionInfo()
