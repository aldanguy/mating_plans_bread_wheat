


# Goal : impute missing data in genotypes 
# Input : genotyping matrix and positions of markers
# Output : imputated genotyping matrix



Sys.time()
cat("\n\nprepare_for_blupf90.R\n\n")
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



titre_lines <- variables[1]
titre_markers_filetred_subset <- variables[2]
titre_genotyping_matrix_filtered_imputed_subset <- variables[3]
titre_phenotyping_data_blupf90 <- variables[4]
titre_map_for_blupf90 <- variables[5]
titre_genotyping_matrix_for_blupf90 <- variables[6]
titre_weights_for_blupf90 <- variables[7]
subset = variables[8]
titre_function_sort_genotyping_matrix = variables[9]
population <- variables[10]
simulation <- variables[11]
run <- as.numeric(variables[12])
h2 <- as.numeric(variables[13])

 
# titre_lines <- "/work2/genphyse/dynagen/adanguy/croisements/150221/value_crosses/lines_estimated_qtls.txt"        
# titre_markers_filetred_subset <-  "/work2/genphyse/dynagen/adanguy/croisements/150221/prepare/markers_filtered.txt"                  
# titre_genotyping_matrix_filtered_imputed_subset <- "/work2/genphyse/dynagen/adanguy/croisements/150221/prepare/genotyping_matrix_filtered_imputed.txt"
# titre_phenotyping_data_blupf90 <- "/work/adanguy/blupf90/pheno/p10TRUE01.txt"                                                        
# titre_map_for_blupf90 <- "/work/adanguy/blupf90/map/m10TRUE01.txt"                                                          
# titre_genotyping_matrix_for_blupf90 <-  "/work/adanguy/blupf90/snp/s10TRUE01.txt"                                                          
# titre_weights_for_blupf90 <-  "/work/adanguy/blupf90/weights/w10TRUE01.txt"                                                      
# subset = "10"                                                                                               
# titre_function_sort_genotyping_matrix ="/work/adanguy/these/croisements/scripts/sort_genotyping_matrix.R"                                 
# population <-  "WE"                                                                                               
# simulation <- "TRUE"                                                                                             
# run <- 1                                                                                               
# generation <- 0                                                                                               
# h2 <- 0.25



source(titre_function_sort_genotyping_matrix)



cat("\n\n INPUT : new ID of varieties with a uniform format \n\n")
lines <- fread(titre_lines)
head(lines)
# column 1 = LINE = ID of variety (string, 3 185 levels = as many as varieties ID)
# column 2 = line2 = modified ID of variety (use in further analysis) (string, 3 185 levels)
# column 3 = phenotyped = variety phenotyped  (logical)
# column 4 = blue = estimate of variety yield (numeric)
# column 5 = genotyped = variety was genotyped (logical)
# column 6 = used_as_parent = variety used as parent (logical)
# dim file : 3185*6



cat("\n\n INPUT : markers with physical position \n\n")
markers <- fread(titre_markers_filetred_subset)
head(markers)
# column 1 = chr = chr ID with letters (string, 21 levels)
# column 2 = region = ID of chr region (string, 5 levels R1, R2a, C, R2b, R3)
# column 4 = pos = physical position of marker (intergers, units bp)
# column 5 = marker = marker ID (string, as many levels as number of markers, here 19806)
# dimension: 19806*5



cat("\n\n OUTPUT : genotyping matrix imputed \n\n")
genotyping_matrix_imputed <- fread(titre_genotyping_matrix_filtered_imputed_subset)
genotyping_matrix_imputed[1:10,1:10]
# column 1 = line 2 = modified ID for variety (string, as many levels as number of lines, i.e. 2089)
# column 2 - 19751 = genotype at each SNP
# dimension: 2089 * 19821


if (simulation !="TRUE"){

lines2 <- lines %>% filter(used_as_parent==T & generation==0) %>%
  dplyr::select(line2, blue) %>% #add run==0
  arrange(line2) %>%
  mutate(blue=ifelse(is.na(blue), 0, blue))

} else if (simulation =="TRUE") {
  
  lines2 <- lines %>% filter(used_as_parent==T & generation==0 ) %>% 
    dplyr::select(one_of("line2",  paste0("blue_qr_",subset,"cm_h",h2,"_r",run))) %>%
    arrange(line2) %>%
    rename(blue:=!!paste0("blue_qr_",subset,"cm_h",h2,"_r",run)) %>%
    mutate(blue=ifelse(is.na(blue), 0, blue))
  
  
}

markers  <- markers %>% arrange(chr, pos, marker)
colonne_markers <- colnames(markers)[grep(population,colnames(markers))]
markers[,"dcum"] <- markers[,colonne_markers]

if (subset !="all"){
  
  cM = as.numeric(subset)
  
  genetic_map_subset <- markers %>%
    mutate(segment=plyr::round_any(dcum, cM))%>%
    group_by(chr, segment) %>%
    dplyr::mutate(n=rep(1:n())) %>%
    filter(n==n()) %>%
    ungroup() 
} else {
  
  
  genetic_map_subset <- markers
  
}  




genetic_map_subset2 <- genetic_map_subset %>% arrange(chr, pos, marker) %>%
  dplyr::select(marker, chr, pos) %>%
  filter(marker %in% genetic_map_subset$marker) %>%
  rename(SNP_ID=marker, CHR=chr, POS=pos) %>%
  mutate(CHR=as.numeric(as.factor(CHR)))


weights <- rep(1, times=nrow(genetic_map_subset2))


genotyping_matrix_imputed <- sort_genotyping_matrix(genotyping_matrix_imputed, genetic_map_subset %>% 
                                                      arrange(chr, pos, marker) %>%
                                                      dplyr::select(marker, chr, pos) %>%
                                                      filter(marker %in% genetic_map_subset$marker))

# 5 represent missing value for blupf90
genotyping_matrix_imputed[is.na(genotyping_matrix_imputed)] <- 5

genotyping <- genotyping_matrix_imputed %>%
  mutate_at(vars(starts_with("AX")), funs(as.integer(as.character(.)))) %>%
  unite(SNP, starts_with("AX"), sep="")%>%
  dplyr::select(line2, SNP) 



cat("\n\n OUPUT : phenotyping data for BLUPF90 \n\n")
head(lines2)
dim(lines2)
write.table(lines2, titre_phenotyping_data_blupf90, col.names = F, row.names = F, dec=".", sep=" ", quote=F)
# column 1 = line2 = modified ID of variety (string, 840 levels)
# column 2 = blue = genotypic value of the line




cat("\n\n OUTPUT : file for blupf90 \n\n")
head(genetic_map_subset2)
dim(genetic_map_subset2)
# column 1 = SNP_ID = marker ID (string, as many levels as number of markers, here 19 750)
# column 2 = CHR = chr number code (integers but factors, 21 levels)
# column 3 = POS = physical position of marker (intergers, units bp)
# dimension: 19 750*4
write.table(genetic_map_subset2, titre_map_for_blupf90, col.names = T, row.names = F, quote=F, dec=".", sep=" ")



cat("\n\n OUTPUT : file for blupf90 n°2 \n\n")
head(weights)
dim(weights)
# column 1 = weights = weights for each SNP to compute G (numeric)
# dimension: 19 750*1
write.table(weights, titre_weights_for_blupf90, col.names = F, row.names = F, quote=F, dec=".", sep=" ")



cat("\n\n OUPUT : genotyping data for BLUPF90 \n\n")
dim(genotyping)
write.table(genotyping, titre_genotyping_matrix_for_blupf90, col.names = F, row.names = F, dec=".", sep=" ", quote=F)
# column 1 = LINE2 = modified ID of variety (string, 840 levels)
# column 2 = SNP data (0=homozygote recessiv, 1 = heteroyzgote, 2 = homozygote dominant, 5 = missing value) (string, 840 levels)
# dimmension of output : 840 lines * 2 columns

sessionInfo()