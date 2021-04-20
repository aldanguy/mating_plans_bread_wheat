

Sys.time()
cat("\n\nselect_lines_crossval.R\n\n")
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


titre_lines_parents <- variables[1]
nbrun <- as.numeric(variables[2])
r_sortie <- variables[3]

p <- fread(titre_lines_parents) %>%
  filter(type=="pheno_simFALSE")


size <- round(0.1*nrow(p))


for (i in 1:nbrun){


individual_to_remove <- data.frame(family_ID=1, ID = sort(sample(p$ID, size=size, replace=F)))
titre_individual_to_remove <- paste0(r_sortie, "lines_to_remove_",i,".txt")


print(head(individual_to_remove))

write.table(individual_to_remove, titre_individual_to_remove, col.names = F, row.names = F, dec=".", sep=" ", quote=F)


}


sessionInfo()