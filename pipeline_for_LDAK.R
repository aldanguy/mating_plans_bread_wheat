



Sys.time()
cat("\n\npreparation_donnes_PLINK.R\n\n")
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

titre_genotyping_matrice_parents <- variables[1]
titre_markers <- variables[2]
titre_lines_parents <- variables[3]
titre_markers_output <- variables[4]
titre_genotyping_output <- variables[5]
titre_phenotypes_output <- variables[5]


 # titre_genotyping_matrice_parents <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/genotyping.txt"
 # titre_markers <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/markers.txt"
 # titre_lines_parents <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/lines_estimated.txt"
 # titre_markers_output <- "/work2/genphyse/dynagen/adanguy/croisements/050321/PLINK_markers.map"
 # titre_genotyping_output <- "/work2/genphyse/dynagen/adanguy/croisements/050321/PLINK_markers.ped"




p <- fread(titre_lines_parents) %>%
  filter(type=="pheno_simFALSE") %>%
  arrange(ID)

head(p)
tail(p)
dim(p)

# m <- fread(titre_markers) %>% 
#   filter(population=="WE") %>%
#   mutate(chr=as.numeric(as.factor(chr))) %>%
#   dplyr::select(chr, marker, dcum, pos) %>%
#   arrange(chr, dcum)
# 
# head(m)
# tail(m)
# dim(m)
# 
# g <- fread(titre_genotyping_matrice_parents) %>%
#   arrange(ID) %>%
#   as.data.frame()
# 
# 
# temp <- data.frame()
# 
# for (i in 2:ncol(g)) {
#   
#   geno <- g %>% dplyr::select(i) %>% unlist() %>% as.vector()
# 
#   temp1 <- ifelse(geno==0,"D", ifelse(geno==1,"D", ifelse(geno==2,"A", NA)))
#   temp2 <- ifelse(geno==0,"D", ifelse(geno==1,"A", ifelse(geno==2,"A", NA)))
#   
#   if (i==2){
#   
#   temp <- cbind(temp1, temp2)
#   print(head(temp))
#   
#   
# 
#   } else {
#     
#     
#     temp <- cbind(temp, temp1, temp2)
#     
#   }
#   
#   
#   
# }
# 
# 
# colnames(temp) <- paste0("V", 1:ncol(temp))
# 
# temp <- temp %>% as.data.frame() %>% mutate(family_ID=1,
#                 individual_ID=g$ID,
#                 paternal_ID=0,
#                 maternal_ID=0,
#                 sex=2,
#                 phenotype=p$value) %>%
#   dplyr::select(family_ID, individual_ID, paternal_ID, maternal_ID, sex, phenotype, starts_with("V")) %>%
#   as.data.frame()
# 
# 
# cat("\n\n markers info \n\n")
# head(m)
# tail(m)
# dim(m)

p <- p %>% mutate(family_ID=1) %>%
  dplyr::select(family_ID, ID, value)



# cat("\n\n genotypes info \n\n")
# temp %>% dplyr::select(1:10) %>% head()
# temp %>% dplyr::select(1:10) %>% tail()
# temp %>% dim()


cat("\n\n pheno info \n\n")
p %>% head()
p %>% tail()
p %>% dim()





#write.table(m, titre_markers_output, col.names = F, row.names = F, dec=".", sep=" ", quote=F)
#write.table(temp, titre_genotyping_output, col.names = F, row.names = F, dec=".", sep=" ", quote=F)
write.table(p, titre_phenotypes_output, col.names = F, row.names = F, dec=".", sep=" ", quote=F)

