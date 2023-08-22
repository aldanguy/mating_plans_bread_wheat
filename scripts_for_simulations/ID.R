



# Goal : Give a new ID to lines, identify lines which are genotyped and/or phenotyped
# Input : lines names from phenotype file or genotype file
# Output : files giving info about lines and dummy pedigree



Sys.time()
cat("\n\nID.R\n\n")
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



titre_phenotypes_input <- variables[1]
titre_genotyping_input <- variables[2]
titre_lines_output <- variables[3]
titre_pedigree_output <- variables[4]

# titre_phenotypes <- "/work/adanguy/these/croisements/amont/Traitees_IS.txt"
# titre_genotyping_matrix_raw <- "/work/adanguy/these/croisements/amont/matrix_nonimput_withoutOTV_names.txt"
# titre_lines <- "/work/adanguy/these/croisements/180120/lines.txt"

cat("\n\n INPUT : phenotypes \n\n")
fread(titre_phenotypes_input) %>% arrange(LINE) %>% head()
fread(titre_phenotypes_input) %>% arrange(LINE) %>% tail()
fread(titre_phenotypes_input) %>% dim()



cat("\n\n INPUT : genotyping data \n\n")
suppressWarnings(fread(titre_genotyping_input)) %>% arrange(V1) %>% select(1:10) %>% slice(1:10)
suppressWarnings(fread(titre_genotyping_input)) %>% arrange(V1) %>% select(1:10) %>% slice((nrow(.)-10) : nrow(.))
suppressWarnings(fread(titre_genotyping_input)) %>% dim()


phenotyped_lines <- fread(titre_phenotypes_input) %>%
  dplyr::select(LINE) %>%
  unlist() %>% 
  as.vector() %>% 
  unique()

genotyped_lines <- suppressWarnings(fread(titre_genotyping_input, select=1)) %>% unlist() %>% as.vector()
list_lines <- unique(c(phenotyped_lines, genotyped_lines))

lines <- data.frame(LINE=list_lines) %>%
  mutate(LINE=as.character(LINE)) %>%
  mutate(ID=paste0(LINE,"_XXX")) %>%
  mutate(ID=gsub("\\s", "0", format(ID, width=max(nchar(ID))))) %>%
  arrange(ID) %>%
  mutate(phenotyped = LINE %in% phenotyped_lines) %>%
  mutate(genotyped = LINE %in% genotyped_lines)


pedigree <- data.frame(ID=lines$ID, P1=NA, P2=NA) %>%
  arrange(ID)



cat("\n\n OUTPUT : lines info \n\n")
head(lines)
tail(lines)
dim(lines)
write.table(lines, titre_lines_output, col.names = T, row.names = F, dec=".", sep="\t", quote=F)



cat("\n\n OUTPUT : pedigree \n\n")
head(pedigree)
tail(pedigree)
dim(pedigree)
write.table(pedigree, titre_pedigree_output, col.names = T, row.names = F, dec=".", sep="\t", quote=F)


sessionInfo()