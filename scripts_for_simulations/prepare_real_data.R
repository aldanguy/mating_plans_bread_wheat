


Sys.time()
cat("\n\nprepare_real_data.R\n\n")
rm(list = ls())
graphics.off()
set.seed(1)
t1 <- Sys.time()

suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(compiler))
suppressPackageStartupMessages(library(readr))


variables <- commandArgs(trailingOnly=TRUE)
cat("\n\nVariables : \n")
print(variables)
cat("\n\n")








titre_lines_input <- variables[1]
simulation <- variables[2]
qtls <- variables[3]
qtls_info <- variables[4]
heritability <- variables[5]
population <- variables[6]
population_ID <- variables[7]
titre_lines_output <- variables[8]




cat("\n\n INPUT : markers \n\n")
l <- fread(titre_lines_input) 
head(l)
tail(l)
dim(l)


l2 <- l %>% dplyr::select(ID, value) %>%
  mutate(simulation=!!simulation,
         qtls=!!qtls,
         qtls_info=!!qtls_info,
         heritability=!!heritability,
         population=!!population,
         population_ID=!!population_ID) %>%
  mutate(info="phenotypes") %>%
  arrange(ID) %>%
  dplyr::select(ID, value, info, simulation, qtls, qtls_info, heritability, population, population_ID)





cat("\n\n phenotypes of parents \n\n")
head(l2)
tail(l2)
dim(l2)
write_delim(l2, titre_lines_output, delim = "\t", na = "NA", append = F,  col_names = T, quote_escape = "none")





sessionInfo()