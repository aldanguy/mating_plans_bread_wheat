

# Goal: prepare files for optimization softwares

Sys.time()
cat("\n\n11_prepare_for_optimization_softwares.R\n\n")
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



titre_criteria_input <- variables[1]
titre_criteria_output <- variables[2]






cat("\n\n INPUT : criteria \n\n")
c <- fread(titre_criteria_input)
head(c)
tail(c)
dim(c)


cf <- c %>% rename(gebv=expected_progeny, sd=sd_progeny, logw=proba_lower_treshold) %>%
  dplyr::select(P1, P2, sd, gebv, logw, uc, uc_extreme) %>%
  arrange(P1, P2)

cat("\n\n OUTPUT : file for ga \n\n")
head(cf)
tail(cf)
dim(cf)
write.table(cf, titre_criteria_output, col.names = T, row.names = F, quote=F, dec=".", sep=" ")


sessionInfo()