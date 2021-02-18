


# Goal : filter genotyping dataset
# Input : genotyping matrix, id of lines
# Output : updated genotyping matrix



Sys.time()
cat("\n\norder.R\n\n")
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



titre_genotyping_matrix_updated <- variables[1]
titre_markers_initial <- variables[2]
titre_markers <- variables[3]
# 
# titre_genotyping_matrix_updated <- "/work/adanguy/these/croisements/050221/genotyping_matrix_filtered.txt"
# titre_markers_initial <-  "/work/adanguy/these/croisements/amont/markers_raw.txt"                
# titre_markers <- "/work/adanguy/these/croisements/050221/markers_filtered.txt"     



cat("\n\n INPUT : markers with physical position \n\n")
markers_initial <- fread(titre_markers_initial)
head(markers_initial)
dim(markers_initial)
# column 1 = chr = chr ID with letters (string, 21 levels)
# column 2 = region = ID of chr region (string, 5 levels R1, R2a, C, R2b, R3)
# column 4 = pos = physical position of marker (intergers, units bp)
# column 5 = marker = marker ID (string, as many levels as number of markers, here 19 750)
# dimension: 19 750*5







cat("\n\n INPUT : gentyping matrix updated \n\n")
genotyping_matrix_updated <- fread(titre_genotyping_matrix_updated)
genotyping_matrix_updated[1:10,1:10]
dim(genotyping_matrix_updated)
# column 1 = line 2 = modified ID for variety (string, as many levels as number of lines, i.e. 2089)
# column 2 - 19751 = genotype at each SNP
# dimension: 2089 * 19821

markers <- markers_initial %>% filter(marker %in% colnames(genotyping_matrix_updated)) %>%
  arrange(chr, pos)

# keep marker present both in genotyped matrix and in positon file

order <- match(markers$marker, colnames(genotyping_matrix_updated))
order <- order[which(!is.na(order))]

order <- colnames(genotyping_matrix_updated)[order] 
genotyping_matrix_updated <- genotyping_matrix_updated %>% dplyr::select(line2, all_of(order))%>% arrange(line2) %>% as.data.frame()


cat("\n\n INPUT : markers with physical position \n\n")
head(markers)
dim(markers)
write.table(markers, titre_markers, col.names=T, row.names=F, quote=F, dec=".", sep="\t")
# column 1 = chr = chr ID with letters (string, 21 levels)
# column 2 = region = ID of chr region (string, 5 levels R1, R2a, C, R2b, R3)
# column 4 = pos = physical position of marker (intergers, units bp)
# column 5 = marker = marker ID (string, as many levels as number of markers, here 19806)
# dimension: 19806*5




cat("\n\n INPUT : gentyping matrix updated \n\n")
genotyping_matrix_updated[1:10,1:10]
dim(genotyping_matrix_updated)
write.table(genotyping_matrix_updated, titre_genotyping_matrix_updated, col.names=T, row.names=F, quote=F, dec=".", sep="\t")
# column 1 = line 2 = modified ID for variety (string, as many levels as number of lines, i.e. 2089)
# column 2 - 19807 = genotype at each SNP
# dimension: 2089 * 19807


sessionInfo()
