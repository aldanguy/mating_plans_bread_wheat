

# kept crosses with high enough expected mean of proegny, to reduce computation time

Sys.time()
cat("\n\n10_keep_crosses_with_high_expected_progeny.R\n\n")
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
proportion_of_best_crosses_used <- as.numeric(variables[2])
titre_criteria_output  <- variables[3]

cat("\n\n INPUT : crosses \n\n")
c <- fread(titre_criteria_input)
head(c)
tail(c)
dim(c)





cf <- c %>% 
  arrange(desc(expected_progeny)) %>%
  slice(1:floor(proportion_of_crosses_used*nrow(.))) %>%
  arrange(P1, P2)


cat("\n\n OUTPUT : crosses filtered \n\n")
head(cf)
tail(cf)
dim(cf)

write.table(cf, titre_criteria_output, col.names=T, row.names=F, dec=".", sep="\t", quote=F)


sessionInfo()