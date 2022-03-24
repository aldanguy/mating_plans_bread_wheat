

# Goal : Produce a standardized map for each genetic_map to compute variance-covariance matrix of progeny genotype
# Input : recombination profiles of several genetic_maps
# Output : standardized genetic map for each pop



Sys.time()
cat("\n\nprepare_genetic_map.R\n\n")
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



titre_genetic_maps_input <- variables[1]
titre_genetic_map_temp_output <- variables[2]



# titre_historical_genetic_maps <- "/home/adanguydesd/Documents/These_Alice/recombinaison/pipeline/020820/genetic_map_specific_meiotic_rec_rates.txt"
# titre_csre_genetic_map <-"/home/adanguydesd/Documents/These_Alice/recombinaison/pipeline/020820/csre_genetic_map.txt"
# titre_genetic_map <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/genetic_maps.txt"
# titre_genetic_map <- "/home/adanguydesd/Documents/These_Alice/recombinaison/pipeline/020820/tabs/supplementary_file_3_recombination_maps.txt"





cat("\n\n INPUT : genetic maps \n\n")
fread(titre_genetic_maps_input) %>% head()
fread(titre_genetic_maps_input) %>% tail()
fread(titre_genetic_maps_input) %>% dim()

genetic_maps <- fread(titre_genetic_maps_input) %>% dplyr::select(population) %>% unique() %>% unlist() %>% as.vector()

for (genetic_map in genetic_maps){
  
  print(genetic_map)
  
  genetic_map2 <- fread(titre_genetic_maps_input) %>%
    rename(genetic_map=population) %>% 
    filter(genetic_map==!!genetic_map) %>%
    mutate(l=posr-posl) %>%
    mutate(d=meiotic_rec_rate*(l/1e6)) %>%
    dplyr::select(genetic_map, chr, region, SNPr, posr, meiotic_rec_rate, d) %>%
    rename(gen=meiotic_rec_rate, marker=SNPr, pos=posr) %>%
    arrange(genetic_map, chr, pos) %>%
    group_by(genetic_map, chr) %>%
    mutate(dcum=cumsum(d)) %>%
    dplyr::select(genetic_map, chr, region, pos, marker, dcum ) %>%
    arrange(chr, pos, marker)  %>%
    as.data.frame()
  
  titre_genetic_map_output <- paste0(titre_genetic_map_temp_output,"_", genetic_map,".txt")
  
  cat("\n\n Output 1 : genetic map \n\n")
  genetic_map2 %>% head() %>% print()
  genetic_map2 %>% tail() %>% print()
  genetic_map2 %>% dim() %>% print()
  
  write.table(genetic_map2, titre_genetic_map_output, col.names = T, row.names = F, quote=F, dec=".", sep="\t")
  
  
  
}


sessionInfo()
