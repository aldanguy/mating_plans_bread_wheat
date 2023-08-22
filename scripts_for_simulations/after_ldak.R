

Sys.time()
cat("\n\nsafter_ldak.R\n\n")
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


titre_gebv <- variables[1]
rr <- as.numeric(variables[2])
titre_output <- variables[3]


output <- fread(titre_gebv)
head(output)
tail(output)
dim(output)

output <- output%>%
  dplyr::select(ID2, Profile_1) %>%
  rename(ID=ID2, gebv=Profile_1) %>%
  mutate(model="ldak") %>%
  mutate(rep=rr)


cat("\n\n gebv info \n\n")
head(output)
tail(output)
dim(output)

write.table(output, titre_output, col.names = F, row.names = F, dec=".", sep=" ", quote=F)


sessionInfo()

sessionInfo()