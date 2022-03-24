


Sys.time()
cat("\n\nconvert_geno_to_haplo.R\n\n")
rm(list = ls())
graphics.off()
set.seed(1)
t1 <- Sys.time()

suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(compiler))
suppressPackageStartupMessages(library(readr))


variables <- commandArgs(trailingOnly=TRUE)
cat("\n\nVariables : \n")
print(variables)
cat("\n\n")








titre_genotyping_input <- variables[1]
titre_markers_input <- variables[2]
titre_haplotypes_output <- variables[3]


cat("\n\n INPUT : genotyping \n\n")
parental_genotypes <- fread(titre_genotyping_input)
parental_genotypes %>% select(1:10) %>% head()
parental_genotypes %>% select(1:10) %>% tail()
parental_genotypes %>% dim()


cat("\n\n INPUT : markers \n\n")
markers <- fread(titre_markers_input) %>% arrange(chr, dcum, marker)
head(markers)
tail(markers)
dim(markers)


haplo_1 <- parental_genotypes %>% 
  dplyr::select(ID, starts_with("AX")) %>%
  arrange(ID) %>%
  mutate(haplo=paste0(ID,"_haplo1")) 

haplo_2 <- parental_genotypes %>% 
  dplyr::select(ID, starts_with("AX")) %>%
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
  as.data.frame() %>%
  inner_join(parental_genotypes %>% dplyr::select(-starts_with("AX")), by="ID") %>%
  arrange(ID, haplo) %>%
  dplyr::select(ID, haplo, one_of("simulation", "qtls", "qtls_info", "heritability", "genomic", "population", "population_ID" ), one_of(markers$marker) )




cat("\n\n genotypes of parents \n\n")
haplotypes %>% dplyr::select(1:15) %>% head()
haplotypes %>% dplyr::select(1:15) %>% tail()
dim(haplotypes)
write_delim(haplotypes, titre_haplotypes_output, delim = "\t", na = "NA", append = F,  col_names = T, quote_escape = "none")






sessionInfo()