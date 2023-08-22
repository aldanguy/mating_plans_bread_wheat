

Sys.time()
cat("\n\nprepare_phenotypes_maize.R\n\n")
rm(list = ls())
graphics.off()
set.seed(1)

suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(compiler))
suppressPackageStartupMessages(library(synbreed))



variables <- commandArgs(trailingOnly=TRUE)
cat("\n\nVariables : \n")
print(variables)
cat("\n\n")


titre_genotyping <- variables[1]
titre_map <- variables[2]
titre_correspondance_ID <- variables[3]
titre_function_sort_genotyping_matrix <- variables[4]
nbcores <- as.numeric(variables[5])
titre_genotyping_output <- variables[6]
titre_markers_output <- variables[7]



