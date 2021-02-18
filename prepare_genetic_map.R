

# Goal : Produce a standardized map for each population to compute variance-covariance matrix of progeny genotype
# Input : recombination profiles of several populations
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



titre_genetic_maps_initial <- variables[1]
titre_genetic_map_temp <- variables[2]



# titre_historical_genetic_maps <- "/home/adanguydesd/Documents/These_Alice/recombinaison/pipeline/020820/population_specific_meiotic_rec_rates.txt"
# titre_csre_genetic_map <-"/home/adanguydesd/Documents/These_Alice/recombinaison/pipeline/020820/csre_genetic_map.txt"
# titre_genetic_map <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/genetic_maps.txt"
# titre_genetic_map <- "/home/adanguydesd/Documents/These_Alice/recombinaison/pipeline/020820/tabs/supplementary_file_3_recombination_maps.txt"





cat("\n\n INPUT : historical genetic maps \n\n")
genetic_map <- fread(titre_genetic_maps_initial)
head(genetic_map)
dim(genetic_map)
# column 1 = population = population ID (string, 4 levels WE EE, WA, EA)
# column 2 = chr = chr ID (string, 21 levels)
# column 3 = region = ID of chr region (string, 5 levels R1, R2a, C, R2b, R3)
# column 4 = posl = physical position of left marker of the interval (interger, units pb)
# column 5 = posr = physical position of right marker of the interval (interger, units pb)
# column 6 = SNPl = marker ID of left marker of the interval (string, as many levels as number of marker -1). Number of marker = 170 002 in WE ; 160 564 in EE, 171 354 in WA and 131 078 in EA
# column 7 = SNPr = marker ID of right marker of the interval (string, as many levels as number of marker -1)
# column 9 = meiotic_rec_rate = meiotic recombination rate of the interval (numeric, units cM)
# column 9 and 10 = no importance here


for (population in unique(genetic_map$population)){

genetic_map2 <- genetic_map %>%
  filter(population==!!population) %>%
  mutate(l=posr-posl) %>%
  mutate(d=meiotic_rec_rate*(l/1e6)) %>%
  dplyr::select(population, chr, region, SNPr, posr, meiotic_rec_rate, d) %>%
  rename(gen=meiotic_rec_rate, marker=SNPr, pos=posr) %>%
  arrange(population, chr, pos) %>%
  group_by(population, chr) %>%
  mutate(dcum=cumsum(d)) %>%
  dplyr::select(population, chr, region, pos, marker, dcum ) %>%
  arrange(chr, pos) 

titre_genetic_map <- paste0(titre_genetic_map_temp,"_", population,".txt")

cat("\n\n Output 1 : genetic map \n\n")
print(head(genetic_map2))
dim(genetic_map2)
# column 1 = population = population ID (string, 5 levels CsRe, WE, EE, WA, EA)
# column 2 = chr = chr ID (string, 21 levels)
# column 3 = region = ID of chr region (string, 5 levels R1, R2a, C, R2b, R3)
# column 4 = pos = physical position of marker (interger, units pb)
# column 5 = marker = marker ID (string, as many levels as number of markers) Number of marker = 170 002 in WE ; 160 564 in EE, 171 354 in WA and 131 078 in EA and 79 544 for CsRe
# column 6 = dcum = cumulated genetic distance of marker since start of the chromosome (numeric, units cM)

write.table(genetic_map2, titre_genetic_map, col.names = T, row.names = F, quote=F, dec=".", sep="\t")



}


sessionInfo()
