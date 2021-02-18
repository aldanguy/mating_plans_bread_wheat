


# Goal : extract a subset of markers
# Input : markers and genetic map
# Output : subset of markers




Sys.time()
cat("\n\nsubset_markers.R\n\n")
rm(list = ls())
graphics.off()
set.seed(1)

suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(compiler))
suppressPackageStartupMessages(library(plyr))




variables <- commandArgs(trailingOnly=TRUE)
cat("\n\nVariables : \n")
print(variables)
cat("\n\n")



titre_markers_filtered <- variables[1]
titre_genotyping_matrix_filtered_imputed <- variables[2]
cM <- as.numeric(variables[3])
titre_genotyping_matrix_filtered_imputed_subset <- variables[4]
titre_markers_filtered_subset <- variables[5]
titre_function_sort_genotyping_matrix <- variables[6]
population <- variables[7]


# titre_markers_filtered <-"/work/adanguy/these/croisements/180121/markers_filtered.txt"                         
# titre_genotyping_matrix_filtered_imputed <-"/work/adanguy/these/croisements/amont/genotyping_matrix_filtered_imputed.txt"        
# cM <- 1                                                                                   
# titre_genotyping_matrix_filtered_imputed_subset <- "/work/adanguy/these/croisements/180121/genotyping_matrix_filtered_imputed_subset.txt"
# titre_markers_filtered_subset <-  "/work/adanguy/these/croisements/180121/markers_filtered_subset.txt" 
# 
# 

source(titre_function_sort_genotyping_matrix)


cat("\n\n OUTPUT : genetic map for the specific SNP dataset \n\n")
markers <- fread(titre_markers_filtered)
head(markers)
# column 1 = chr = chr ID with letters (string, 21 levels)
# column 2 = region (string, 5 levels)
# column 3 = pos = physical position of marker (intergers, units bp)
# column 4 = marker = marker ID (string, as many levels as number of markers)
# column 5 = dcum = cumulated genetic distance since chromsome start (numeric, units cM)



cat("\n\n INPUT : gentyping matrix imputed \n\n")
genotyping_matrix_imputed <- fread(titre_genotyping_matrix_filtered_imputed)
genotyping_matrix_imputed[1:10,1:10]
# column 1 = line 2 = modified ID for variety (string, as many levels as number of lines, i.e. 2089)
# column 2 - 19751 = genotype at each SNP
# dimension: 2089 * 19821


colonne_genetic_map <- colnames(markers)[grep(population,colnames(markers))]
markers[,"dcum"] <- markers[,colonne_genetic_map]

markers2 <- markers %>% mutate(segment=round_any(dcum, cM))%>%
  group_by(chr, segment) %>%
  dplyr::mutate(n=rep(1:n())) %>%
  filter(n==n()) %>%
  ungroup() %>%
  dplyr::select(chr, region, pos, marker,  dcum_WE, dcum_EE, dcum_WA, dcum_EA, dcum_CsRe) %>%
  arrange(chr, pos)


genotyping_matrix_imputed_subset <- sort_genotyping_matrix(genotyping_matrix_imputed, markers2)


head(markers2)
write.table(markers2, titre_markers_filtered_subset, col.names = T, row.names = F, dec=".", sep="\t", quote=F)
# column 1 = chr = chr ID with letters (string, 21 levels)
# column 2 = region (string, 5 levels)
# column 3 = pos = physical position of marker (intergers, units bp)
# column 4 = marker = marker ID (string, as many levels as number of markers)
# column 5 = dcum = cumulated genetic distance since chromsome start (numeric, units cM)


cat("\n\n OUTPUT : gentyping matrix imputed \n\n")
genotyping_matrix_imputed[1:10,1:10]
# column 1 = line 2 = modified ID for variety (string, as many levels as number of lines, i.e. 2089)
# column 2 - 19751 = genotype at each SNP
# dimension: 2089 * 19821
write.table(genotyping_matrix_imputed_subset, titre_genotyping_matrix_filtered_imputed_subset, col.names = T, row.names = F, quote=F, dec=".", sep="\t")




sessionInfo()