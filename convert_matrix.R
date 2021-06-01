


Sys.time()
cat("\n\nconvert_matrix.R\n\n")
rm(list = ls())
graphics.off()
set.seed(1)
suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(compiler))

# 
# titre_l <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/LDAK-Thin.grm.raw"
# titre_output <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/g_user"




variables <- commandArgs(trailingOnly=TRUE)
cat("\n\nVariables : \n")
print(variables)
cat("\n\n")



titre_l <- variables[1]
titre_output <- variables[2]

cat("\n\n INPUT G matrix from ldak \n\n")
l <- fread(titre_l) %>% as.data.frame()
l %>% dplyr::select(1:10) %>% head()
l %>% dplyr::select(1:10) %>% tail()
dim(l)


index1 <- as.numeric()
index2 <- as.numeric()
for (i in 1:nrow(l)){
  
  
  index1 <- c(index1, rep(1:i))
  index2 <- c(index2, rep(i, times=i))
  
  
}


l2<- data.frame(index1=index1, index2=index2, value=l[upper.tri(l, diag=T)])

cat("\n\n OUPUT G matrix for blupf90 \n\n")

head(l2)
tail(l2)
dim(l2)

write.table(l2, titre_output, col.names = F, dec=".", sep=" ", quote=F, row.names = F)

sessionInfo()
