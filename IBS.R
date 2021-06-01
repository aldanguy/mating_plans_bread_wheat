
Sys.time()
cat("\n\nIBS.R\n\n")
rm(list = ls())
graphics.off()
set.seed(1)

suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(compiler))
suppressPackageStartupMessages(library(viridis))




variables <- commandArgs(trailingOnly=TRUE)
cat("\n\nVariables : \n")
print(variables)
cat("\n\n")



titre_genotyping <- variables[1]
titre_markers <- variables[2]
titre_ibs_output <- variables[3]


# titre_genotyping <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/genotyping.txt"
# titre_markers <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/markers_WE.txt"
# 


cat("\n\n geno info \n\n")

geno <- fread(titre_genotyping)
geno %>% dplyr::select(1:10) %>% head()
geno %>% dplyr::select(1:10) %>% tail()
geno %>% dim()



cat("\n\n markers info \n\n")
markers <- fread(titre_markers)
head(markers)
tail(markers)
dim(markers)


markers <- markers %>%
  mutate(segment=plyr::round_any(dcum, 1))%>%
  group_by(chr, segment) %>%
  slice(n=sample(1:n(), size=1, replace=F)) %>%
  ungroup() 


geno <- geno %>% dplyr::select(one_of(markers$marker)) 


ibs <- matrix(data=NA, nrow=nrow(geno), ncol=nrow(geno))
colnames(ibs) <- as.vector(unlist(fread(titre_genotyping, header=T, select = 1)))
rownames(ibs) <- as.vector(unlist(fread(titre_genotyping, header=T, select = 1)))
for (i in 1:(nrow(geno)-1)){
  
  print(i)
  
  for (j in (i+1):nrow(geno)){
    
    
    ibs[i,j] <- sum(abs(as.vector(geno[i, ]) - as.vector(geno[j,])))/(2*ncol(geno))
    ibs[j,i] <- ibs[i,j]
    
  }

}


diag(ibs) <- 1
ibs <- as.data.frame(ibs)


cat("\n\n IBS info \n\n")
ibs %>% dplyr::select(1:10) %>% head()
ibs %>% dplyr::select(1:10) %>% tail()
ibs %>% dim()


write_delim(ibs, titre_ibs_output, delim = "\t", na = "NA", append = F,  col_names = T, quote_escape = "none")
