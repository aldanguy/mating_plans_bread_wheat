


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


variables <- commandArgs(trailingOnly=TRUE)
cat("\n\nVariables : \n")
print(variables)
cat("\n\n")



titre_lines_input <- variables[1]
titre_markers_input <- variables[2]
titre_genotyping_input <- variables[3]
titre_phenotyping_blupf90 <- variables[4]
titre_markers_blupf90 <- variables[5]
titre_genotyping_blupf90 <- variables[6]
titre_weights_blupf90 <- variables[7]
titre_function_sort_genotyping_matrix = variables[8]
titre_function_subset_markers <- variables[9]
type <- variables[10]


# titre_lines_input <-  "/work2/genphyse/dynagen/adanguy/croisements/200421/value_crosses/lines_estimated.txt"     
# titre_markers_input <- "/work2/genphyse/dynagen/adanguy/croisements/200421/prepare/markers.txt"   
# titre_genotyping_input <-  "/work2/genphyse/dynagen/adanguy/croisements/200421/prepare/genotyping.txt"
# titre_phenotyping_blupf90 <- "psimFALSE.gbasic.txt"                                                     
# titre_markers_blupf90 <-  "msimFALSE.gbasic.txt"                                                     
# titre_genotyping_blupf90 <- "ssimFALSE.gbasic.txt"                                                     
# titre_weights_blupf90 <-  "wsimFALSE.gbasic.txt"                                                     
# titre_function_sort_genotyping_matrix ="/work/adanguy/these/croisements/scripts/sort_genotyping_matrix.R"         
# titre_function_subset_markers <- "/work/adanguy/these/croisements/scripts/subset_markers.R"                 
# population <- "WE"                                                                       
# type <- "simTRUE_chr_h0.8_r7_gbasic"   


source(titre_function_sort_genotyping_matrix)
source(titre_function_subset_markers)



cat("\n\n INPUT : lines info \n\n")
fread(titre_lines_input) %>% arrange(ID, type) %>% head()
fread(titre_lines_input) %>% arrange(ID, type)%>% tail()
fread(titre_lines_input) %>% arrange(ID, type) %>% head()
fread(titre_lines_input) %>% dim()

cat("\n\n INPUT : markers info \n\n")
fread(titre_markers_input) %>% head()
fread(titre_markers_input) %>% tail()
fread(titre_markers_input) %>% dim()

cat("\n\n INPUT : genotyping data \n\n")
fread(titre_genotyping_input) %>% select(1:10) %>% slice(1:10)
fread(titre_genotyping_input) %>% select(1:10) %>% slice((nrow(.)-10):nrow(.))
fread(titre_genotyping_input)%>% dim()







lines2 <- fread(titre_lines_input)  %>% 
  arrange(ID) %>%
  dplyr::select(ID, value)



markers2 <- fread(titre_markers_input) %>% 
  arrange(chr, pos, marker, population) %>%
  dplyr::select(chr, dcum, pos, marker) 

#genetic_map_subset1 <- subset_genetic_map(genetic_map_raw=markers2, population=population, cM=subset) # sample markers which are QTLs in case of simulation

genetic_map_subset2 <- markers2%>%
  rename(SNP_ID=marker, CHR=chr, POS=pos) %>%
  mutate(CHR=as.numeric(as.factor(CHR))) %>%
  as.data.frame()  %>%
  dplyr::select(SNP_ID, CHR, POS) %>%
  unique()


weights <- rep(1, times=nrow(genetic_map_subset2))


genotyping <- sort_genotyping_matrix(fread(titre_genotyping_input), markers2) %>%
  filter(ID %in% lines2$ID)

# 5 represent missing value for blupf90
genotyping[is.na(genotyping)] <- 5

genotyping <- genotyping %>%
  mutate_at(vars(starts_with(c("AX","rs"))), funs(as.integer(as.character(.)))) %>%
  unite(SNP, starts_with(c("AX","rs")), sep="")%>%
  dplyr::select(ID, SNP) 



cat("\n\n OUPUT : phenotyping data for BLUPF90 \n\n")
head(lines2)
tail(lines2)
dim(lines2)
write.table(lines2, titre_phenotyping_blupf90, col.names = F, row.names = F, dec=".", sep=" ", quote=F)




cat("\n\n OUTPUT : markers for blupf90 \n\n")
head(genetic_map_subset2)
tail(genetic_map_subset2)
dim(genetic_map_subset2)
write.table(genetic_map_subset2, titre_markers_blupf90, col.names = T, row.names = F, quote=F, dec=".", sep=" ")



cat("\n\n OUTPUT : weights file for blupf90 \n\n")
head(weights)
tail(weights)
length(weights)
write.table(weights, titre_weights_blupf90, col.names = F, row.names = F, quote=F, dec=".", sep=" ")



cat("\n\n OUPUT : genotyping data for BLUPF90 \n\n")
genotyping %>% dim()
print(nchar(genotyping[1,2]))
write.table(genotyping, titre_genotyping_blupf90, col.names = F, row.names = F, dec=".", sep=" ", quote=F)
# column 1 = LINE2 = modified ID of variety (string, 840 levels)
# column 2 = SNP data (0=homozygote recessiv, 1 = heteroyzgote, 2 = homozygote dominant, 5 = missing value) (string, 840 levels)
# dimmension of output : 840 lines * 2 columns

sessionInfo()