

suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(compiler))



sort_genotyping_matrix <- function(genotyping_matrix_file, markers_file){
  
  
  ordre_marqueurs <- markers_file %>%
    arrange(chr, pos) %>%
    dplyr::select(marker) %>%
    unlist() %>%
    as.vector()
  
  colonnes_genotyping_matrix_file <- colnames(genotyping_matrix_file)
  
  
  colonnes_marqueurs <- colonnes_genotyping_matrix_file[grep("AX", colonnes_genotyping_matrix_file)]
  colonnes_autres <- colonnes_genotyping_matrix_file[grep("AX", colonnes_genotyping_matrix_file, invert=T)]
  
  colonnes_marqueurs_ordonnes <- colonnes_marqueurs[match(ordre_marqueurs, colonnes_marqueurs)]
  
  genotyping_matrix_file <- genotyping_matrix_file %>% dplyr::select(one_of(colonnes_autres, colonnes_marqueurs_ordonnes)) %>%
    arrange_at(colonnes_autres)
  
  
  return(genotyping_matrix_file)
  
}
