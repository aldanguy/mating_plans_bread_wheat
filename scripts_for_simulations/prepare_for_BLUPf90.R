


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





cat("\n\n INPUT : lines info \n\n")
lines <- fread(titre_lines_input) 
head(lines)
tail(lines)
dim(lines)


cat("\n\n INPUT : markers info \n\n")
markers <- fread(titre_markers_input) 
head(markers)
tail(markers)
dim(markers)

cat("\n\n INPUT : genotyping data \n\n")
g <- fread(titre_genotyping_input) 
g %>% dplyr::select(1:10) %>% head()
g %>% dplyr::select(1:10) %>% tail()
dim(g)






lines2 <- lines  %>% 
  arrange(ID) %>%
  dplyr::select(ID, value) %>%
  mutate(intercept="inter")

if (unique(lines$simulation) == T){

  
genetic_map <- markers %>% 
  filter(value ==0) %>%
    arrange(chr, dcum, marker) %>%
    dplyr::select(chr, dcum, pos, marker) %>%
  rename(SNP_ID=marker, CHR=chr, POS=pos) %>%
  mutate(CHR=as.numeric(as.factor(CHR))) %>%
  as.data.frame()  %>%
  dplyr::select(SNP_ID, CHR, POS) %>%
  unique()

} else if (unique(lines$simulation) == F){
  
  
  
  genetic_map <- markers %>% 
    arrange(chr, dcum, marker) %>%
    dplyr::select(chr, dcum, pos, marker) %>%
    rename(SNP_ID=marker, CHR=chr, POS=pos) %>%
    mutate(CHR=as.numeric(as.factor(CHR))) %>%
    as.data.frame()  %>%
    dplyr::select(SNP_ID, CHR, POS) %>%
    unique()
  
}
  
  


weights <- rep(1, times=nrow(genetic_map))


g2 <- g%>%
  dplyr::select(ID, one_of(genetic_map$SNP_ID)) %>%
  arrange(ID) %>%
  mutate_at(vars(starts_with(c("AX"))), funs(as.integer(as.character(.)))) %>%
  unite(SNP, starts_with(c("AX")), sep="")%>%
  dplyr::select(ID, SNP) 



cat("\n\n OUPUT : phenotyping data for BLUPF90 \n\n")
head(lines2)
tail(lines2)
dim(lines2)
write.table(lines2, titre_phenotyping_blupf90, col.names = F, row.names = F, dec=".", sep=" ", quote=F)




cat("\n\n OUTPUT : markers for blupf90 \n\n")
head(genetic_map)
tail(genetic_map)
dim(genetic_map)
write.table(genetic_map, titre_markers_blupf90, col.names = T, row.names = F, quote=F, dec=".", sep=" ")



cat("\n\n OUTPUT : weights file for blupf90 \n\n")
head(weights)
tail(weights)
length(weights)
write.table(weights, titre_weights_blupf90, col.names = F, row.names = F, quote=F, dec=".", sep=" ")



cat("\n\n OUPUT : genotyping data for BLUPF90 \n\n")
g2 %>% dim()
print(nchar(g2[1,2]))
write.table(g2, titre_genotyping_blupf90, col.names = F, row.names = F, dec=".", sep=" ", quote=F)
# column 1 = LINE2 = modified ID of variety (string, 840 levels)
# column 2 = SNP data (0=homozygote recessiv, 1 = heteroyzgote, 2 = homozygote dominant, 5 = missing value) (string, 840 levels)
# dimmension of output : 840 lines * 2 columns

sessionInfo()