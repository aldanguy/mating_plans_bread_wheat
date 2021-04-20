

# Goal : simulate progeny genotypes
# Input : genotypes of inbred parental lines and number of progenies per cross
# Output : genotypes of progenies


# To install MOBPS
# install.packages("miraculix", configure.args="CXX_FLAGS=-march=native")



Sys.time()
cat("\n\nprepare_for_next_generations.R\n\n")
rm(list = ls())
graphics.off()
set.seed(1)
t1 <- Sys.time()

suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(compiler))




variables <- commandArgs(trailingOnly=TRUE)
cat("\n\nVariables : \n")
print(variables)
cat("\n\n")

titre_best_crosses <- variables[1]
titre_crosses <- variables[2]
titre_best_crosses_output <- variables[3]
titre_crosses_output <- variables[4]
titre_crosses_filtered <- variables[5]



generation <- as.numeric(variables[6])
type <- variables[7]
population  <- variables[8]
critere <- variables[9]
affixe <- variables[10]
rr <- as.numeric(variables[11])

titre_geno_parents <- variables[12]
titre_geno_progeny <- variables[13]
titre_lines_parents <- variables[14]
titre_lines_progeny <- variables[15]
titre_ped_parents <- variables[16]
titre_ped_progeny <- variables[17]
titre_geno_output <- variables[18]
titre_lines_output <- variables[19]
titre_ped_output <- variables[20]


# titre_geno_parents <- "/work2/genphyse/dynagen/adanguy/croisements/150221/prepare/genotyping_matrix_filtered_imputed.txt"                                                 
# titre_geno_progeny <- "/work2/genphyse/dynagen/adanguy/croisements/150221/best_crosses/g2_simFALSE_10cm_WE_gebv_real_rr1/genotypes_g2_simFALSE_10cm_WE_gebv_real_rr1.txt"
# titre_lines_parents <- "/work2/genphyse/dynagen/adanguy/croisements/150221/prepare/lines.txt"
# titre_lines_progeny <- "/work2/genphyse/dynagen/adanguy/croisements/150221/best_crosses/g2_simFALSE_10cm_WE_gebv_real_rr1/lines_g2_simFALSE_10cm_WE_gebv_real_rr1.txt"
# titre_ped_parents <- "/work2/genphyse/dynagen/adanguy/croisements/150221/prepare/pedigree.txt"
# titre_ped_progeny <- "/work2/genphyse/dynagen/adanguy/croisements/150221/best_crosses/g2_simFALSE_10cm_WE_gebv_real_rr1/pedigree_g2_simFALSE_10cm_WE_gebv_real_rr1.txt"
# 
# titre_best_crosses <- "/work2/genphyse/dynagen/adanguy/croisements/150221/best_crosses/g1_simFALSE_10cm_WE_gebv_real/best_crosses_g1_simFALSE_10cm_WE_gebv_real.txt"
# titre_crosses_output
# titre_best_crosses_output






cat("\n\n INPUT : best crosses info \n")
fread(titre_best_crosses) %>% head()
fread(titre_best_crosses) %>% tail()
fread(titre_best_crosses) %>% dim()


cat("\n\n INPUT : crosses info \n")
fread(titre_crosses) %>% head()
fread(titre_crosses) %>% tail()
fread(titre_crosses) %>% dim()


cat("\n\n INPUT : crosses filtered \n")
fread(titre_crosses_filtered) %>% head()
fread(titre_crosses_filtered) %>% tail()
fread(titre_crosses_filtered) %>% dim()


best_crosses <- fread(titre_best_crosses) %>%
  mutate(generation=!!generation -1, type=!!type, population=!!population, critere=!!critere, affixe=!!affixe, rr=!!rr) %>%
  dplyr::select(P1, P2, generation, type, population, critere, affixe, rr, nbprogeny) %>%
  arrange(P1, P2, rr)



cat("\n\n OUTPUT : best crosses info \n")
head(best_crosses)
tail(best_crosses)
dim(best_crosses)
write.table(best_crosses, titre_best_crosses_output, col.names=T, row.names=F, dec=".", sep="\t", quote=F) 


crosses <- fread(titre_crosses)  %>%
  mutate(generation=!!generation-1, type=!!type, population=!!population, critere=!!critere, affixe=!!affixe, rr=!!rr) %>%
  dplyr::select(P1, P2, generation, type, population, critere, affixe, rr, gebv, sd, logw, uc) %>%
  arrange(P1, P2, rr)

crosses_filtered <- fread(titre_crosses_filtered) %>% dplyr::select(P1, P2) %>% mutate(filtered=FALSE, rr=!!rr) 

crosses <- crosses %>% full_join(crosses_filtered, by=c("P1","P2", "rr")) %>%
  mutate(filtered=ifelse(is.na(filtered) & rr==!!rr, TRUE, filtered)) %>%
  arrange(P1, P2, rr)

cat("\n\n OUTPUT : crosses info \n")
head(crosses)
tail(crosses)
dim(crosses)
write.table(crosses, titre_crosses_output, col.names=T, row.names=F, dec=".", sep="\t", quote=F) 









if (generation ==2){
  
  cat("\n\n INPUT : pedigree info of parents \n")
  fread(titre_ped_parents) %>% head() %>% print()
  fread(titre_ped_parents) %>% tail() %>% print()
  fread(titre_ped_parents) %>% dim() %>% print()
  
  cat("\n\n INPUT : pedigree info of progeny \n")
  fread(titre_ped_progeny) %>% head() %>% print()
  fread(titre_ped_progeny) %>% tail() %>% print()
  fread(titre_ped_progeny) %>% dim() %>% print()
  
  cat("\n\n INPUT : lines info of parents \n")
  fread(titre_lines_parents) %>% head() %>% print()
  fread(titre_lines_parents) %>% tail() %>% print()
  fread(titre_lines_parents) %>% dim() %>% print()
  
  cat("\n\n INPUT : lines info of progeny \n")
  fread(titre_lines_progeny) %>% head() %>% print()
  fread(titre_lines_progeny) %>% tail() %>% print()
  fread(titre_lines_progeny) %>% dim() %>% print()
  
  
  cat("\n\n INPUT : genotyping data of parents \n")
  fread(titre_geno_parents)[1:10,1:10]  %>% print()
  fread(titre_geno_parents) %>% dim() %>% print()
  
  cat("\n\n INPUT : genotyping info of progeny \n")
  fread(titre_geno_progeny)[1:10,1:10] %>% print()
  fread(titre_geno_progeny) %>% dim() %>% print()


geno_parents <- fread(titre_geno_parents) %>%
  mutate(generation=1, type=type, population=population, critere=critere, affixe=affixe, rr=rr) %>%
  dplyr::select(ID, generation, type, population, critere, affixe, rr, starts_with("AX"))


geno<- fread(titre_geno_progeny) %>% rbind(., geno_parents) %>%
  arrange(generation, ID)


lines_parents <- fread(titre_lines_parents) %>%
  mutate(generation=1, type=type, population=population, critere=critere, affixe=affixe, rr=rr, used_as_parent=F) %>%
  dplyr::select(ID, generation, type, population, critere, affixe, rr, value, used_as_parent)

lines<- fread(titre_lines_progeny) %>% mutate(used_as_parent=F) %>%
  dplyr::select(ID, generation, type, population, critere, affixe, rr, value, used_as_parent) %>%
  rbind(., lines_parents) %>%
  arrange(generation, ID)


ped_parents <- fread(titre_ped_parents) %>%
  mutate(generation=1, type=type, population=population, critere=critere, affixe=affixe, rr=rr) %>%
  dplyr::select(ID, generation, type, population, critere, affixe, rr, P1, P2)

ped <- fread(titre_ped_progeny) %>%
  dplyr::select(ID, generation, type, population, critere, affixe, rr, P1, P2) %>%
  rbind(., ped_parents) %>%
  arrange(generation, ID)

cat("\n\n OUTPUT : lines info \n")
head(lines) %>% print()
tail(lines) %>% print()
dim(lines) %>% print()

write.table(lines, titre_lines_output, col.names=T, row.names=F, dec=".", sep="\t", quote=F) 


cat("\n\n OUTPUT : pedigree info \n")
head(ped) %>% print()
tail(ped) %>% print()
dim(ped) %>% print()
write.table(ped, titre_ped_output, col.names=T, row.names=F, dec=".", sep="\t", quote=F) 

cat("\n\n OUTPUT : genotyping data \n")
geno %>% select(1:10) %>% slice(1:10)%>% print()
geno %>% select(1:10) %>% slice((nrow(.)-10):nrow(.))%>% print()
geno %>% dim()%>% print()


write.table(geno, titre_geno_output, col.names=T, row.names=F, dec=".", sep="\t", quote=F) 



}


sessionInfo()