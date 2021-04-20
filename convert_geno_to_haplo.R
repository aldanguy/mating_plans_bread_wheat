

# Goal : simulate progeny genotypes
# Input : genotypes of inbred parental lines and number of progenies per cross
# Output : genotypes of progenies


# To install MOBPS
# install.packages("miraculix", configure.args="CXX_FLAGS=-march=native")



Sys.time()
cat("\n\nconvert_geno_to_haplo.R\n\n")
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








titre_genotyping_input <- variables[1]
titre_haplotypes_output <- variables[3]
titre_best_crosses <- variables[2]


cat("\n\n INPUT : genotyping \n\n")
parental_genotypes <- fread(titre_genotyping_input)
parental_genotypes %>% select(1:10) %>% slice(1:10)
parental_genotypes %>% select(1:10) %>% slice((nrow(.)-10):nrow(.))
parental_genotypes %>% dim()


cat("\n\n best crosses info \n\n")
best_crosses <- fread(titre_best_crosses)
head(best_crosses)
tail(best_crosses)
dim(best_crosses)


liste_lines <- best_crosses %>% dplyr::select(P1,P2) %>%
  unlist() %>%
  as.vector() %>%
  unique() %>%
  sort()

haplo_1 <- parental_genotypes %>% 
  dplyr::select(ID, starts_with("AX")) %>%
  filter(ID %in% !!liste_lines) %>%
  arrange(ID) %>%
  mutate(haplo=paste0(ID,"_haplo1")) 

haplo_2 <- parental_genotypes %>% 
  dplyr::select(ID, starts_with("AX")) %>%
  filter(ID %in% !!liste_lines) %>%
  arrange(ID) %>%
  mutate(haplo=paste0(ID,"_haplo2")) %>%
  group_by(ID) %>%
  mutate_at(vars(starts_with("AX")), funs(min(1,.)))  %>% 
  ungroup() 

haplo_2[haplo_1==1] <- 0 # if locus is heterozygote, the sum per locus should be equal to 1

haplotypes <- haplo_1  %>%
  group_by(ID) %>%
  mutate_at(vars(starts_with("AX")), funs(min(1,.))) %>%
  ungroup() %>%
  rbind(.,haplo_2) %>%
  arrange(ID, haplo)  %>% 
  dplyr::select(ID, haplo, starts_with("AX")) %>%
  as.data.frame()



write.table(haplotypes, titre_haplotypes_output, col.names = T, row.names = F, dec=".", sep="\t", quote=F)





sessionInfo()