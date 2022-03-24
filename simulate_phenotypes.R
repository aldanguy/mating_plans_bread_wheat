

Sys.time()
cat("\n\nsimulate_phenotypes.R\n\n")
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



titre_lines_input <- variables[1]
heritability <- as.numeric(variables[2])
titre_phenotypes_output <- variables[3]
population <- variables[4]




cat("\n\n INPUT : lines info \n\n")
l <- fread(titre_lines_input) 
head(l)
tail(l)
dim(l)

population_ID <- unique(l$population_ID)

set.seed(population_ID)


TBV <- l %>%
  dplyr::select(value) %>%
  unlist() %>%
  as.vector() 

variance_TBV=var(TBV, na.rm = T)
print(variance_TBV)



variance_env=((1-heritability)*variance_TBV)/(heritability)
print(variance_env)

phenotypes <- l %>%
  mutate(value=!!TBV+ rnorm(length(TBV), m=0, sd=sqrt(variance_env))) %>%
  mutate(heritability=!!heritability) %>%
  mutate(qtls_info=FALSE) %>%
  mutate(info="phenotypes") %>%
  mutate(population=!!population) %>%
  arrange(ID) %>%
  dplyr::select(ID, value, info, simulation, qtls, qtls_info, heritability, population, population_ID)



mean(phenotypes$value)





cat("\n\n OUPUT : phenotypes info \n\n")
head(phenotypes)
tail(phenotypes)
dim(phenotypes)
write.table(phenotypes, titre_phenotypes_output, col.names = T, row.names = F, dec=".", sep="\t", quote=F)



sessionInfo()