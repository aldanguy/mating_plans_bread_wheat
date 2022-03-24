



Sys.time()
cat("\n\npprepare_for_LDAK.R\n\n")
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

titre_genotypes_parents_input <- variables[1]
titre_markers_input <- variables[2]
titre_markers_output <- variables[3]
titre_genotyping_output <- variables[4]


# 
# titre_genotypes_parents_input <-  "/work2/genphyse/dynagen/adanguy/croisements/110222/real_data_GBLUP/parents/genotypes_real_data_GBLUP.txt"      
# titre_markers_input <-  "/work2/genphyse/dynagen/adanguy/croisements/110222/real_data_GBLUP/gblup/markers_estimated_real_data_GBLUP.txt"
# titre_markers_output <- "/work2/genphyse/dynagen/adanguy/croisements/110222/real_data_GBLUP/LDAK/LDAK_real_data_GBLUP.map"              
# titre_genotyping_output <-  "/work2/genphyse/dynagen/adanguy/croisements/110222/real_data_GBLUP/LDAK/LDAK_real_data_GBLUP.ped"              
# 
# 
# 



cat("\n\n INPUT markers info \n\n")
m <- fread(titre_markers_input) 
head(m)
tail(m)
dim(m)


cat("\n\n INPUT genotyping \n\n")
g <- fread(titre_genotypes_parents_input) 
g %>% dplyr::select(1:10) %>% head()
g %>% dplyr::select(1:10) %>% tail()
g %>% dim()




m <-m %>% 
  mutate(chr=as.numeric(as.factor(chr))) %>%
  dplyr::select(chr, marker, dcum, pos) %>%
  arrange(chr, dcum)

  


g <- g %>%
  arrange(ID) %>%
  as.data.frame()



####
# m <- m %>% slice(sort(sample(1:nrow(m), size=1000, replace=F))) %>%
#   arrange(chr, pos)
# 
# 
# g <- g %>% dplyr::select(one_of(c("ID", m$marker)))
####
# 
# for (i in 2:ncol(g)) {
#   
#   print(i)
#   
#   geno <- g %>% dplyr::select(i) %>% unlist() %>% as.vector()
#   
#   temp1 <- ifelse(geno==0,"D", ifelse(geno==1,"D", ifelse(geno==2,"A", NA)))
#   temp2 <- ifelse(geno==0,"D", ifelse(geno==1,"A", ifelse(geno==2,"A", NA)))
#   
#   if (i==2){
#     
#     temp <- cbind(temp1, temp2)
#     print(head(temp))
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


maf <- apply(g %>% dplyr::select(starts_with("AX")), 2, function(x) 2*length(which(x==2)) + length(which(x==1)))
maf <- maf/(2*nrow(g))
maf <- sapply(maf, function(x) min(1-x, x))
head(maf)
min(maf)
m_to_remove <- colnames(g)[-1][c(which(maf ==0))]

g <- g %>% dplyr::select(-one_of(m_to_remove))
m <- m %>% filter(!marker %in% m_to_remove)


i=1
for (i in 1:nrow(g)) {
  

  geno <- g %>% dplyr::select(starts_with("AX")) %>% slice(i) %>% unlist() %>% as.vector()
  
  temp1 <- ifelse(geno==0,"D", ifelse(geno==1,"D", ifelse(geno==2,"A", NA)))
  temp2 <- ifelse(geno==0,"D", ifelse(geno==1,"A", ifelse(geno==2,"A", NA)))

    test <- t(as.vector(unlist(as.data.frame(rbind(temp1, temp2)))))

  
    write.table(test, titre_genotyping_output, col.names = F, row.names = F, dec=".", sep="\t", quote=F, append=(i>1))

    
    

    

  }
  
  
temp <- fread(titre_genotyping_output, header = F)
temp %>% dplyr::select(1:10) %>% head()
temp %>% dplyr::select(1:10) %>% tail()
dim(temp)

colnames(temp) <- paste0("V", 1:ncol(temp))

temp <- temp %>% 
  as.data.frame() %>% 
  mutate(family_ID=1,
         individual_ID=g$ID,
         paternal_ID=0,
         maternal_ID=0,
         sex=2,
         phenotype=0) %>%
  dplyr::select(family_ID, individual_ID, paternal_ID, maternal_ID, sex, phenotype, starts_with("V")) %>%
  as.data.frame()


cat("\n\n OUTPUT markers info \n\n")
head(m)
tail(m)
dim(m)


cat("\n\n OUTPUT genotypes info \n\n")
temp %>% dplyr::select(1:10) %>% head()
temp %>% dplyr::select(1:10) %>% tail()
temp %>% dim()







write.table(m, titre_markers_output, col.names = F, row.names = F, dec=".", sep=" ", quote=F)
write.table(temp, titre_genotyping_output, col.names = F, row.names = F, dec=".", sep=" ", quote=F)

sessionInfo()
