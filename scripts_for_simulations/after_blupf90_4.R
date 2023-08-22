


# Goal : impute missing data in genotypes 
# Input : genotyping matrix and positions of markers
# Output : imputated genotyping matrix



Sys.time()
cat("\n\nafter_blupf90_4.R\n\n")
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
titre_lines_to_keep <- variables[2]
nbrun <- as.numeric(variables[3])
modele <- variables[4]
titre_lines_output <- variables[5]

cat("\n\n INPUT : lines info \n\n")
lines2 <- fread(titre_lines_input) 
head(lines2)


lines_to_keep <- fread(titre_lines_to_keep)
head(lines_to_keep)

lines2 <- lines2%>%
  rename(ID=V1, gebv=V3)%>%
  mutate(model=modele) %>%
  mutate(rep=nbrun) %>%
  dplyr::select(ID, gebv, model, rep) %>%
  filter(ID %in% lines_to_keep$V2)

head(lines2)
tail(lines2)
dim(lines2)

write.table(lines2, titre_lines_output, col.names = T, row.names = F, dec=".", sep="\t")



sessionInfo()