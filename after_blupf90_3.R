


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
titre_genotyping_input <- variables[2]
titre_genotyping_blupf90 <- variables[3]

 

cat("\n\n INPUT : lines info \n\n")
lines2 <- fread(titre_lines_input)   %>%
  rename(ID=V2)
head(lines2)


cat("\n\n INPUT : genotyping data \n\n")
fread(titre_genotyping_input) %>% select(1:10) %>% slice(1:10)
fread(titre_genotyping_input) %>% select(1:10) %>% slice((nrow(.)-10):nrow(.))
fread(titre_genotyping_input)%>% dim()





genotyping <-  fread(titre_genotyping_input)



genotyping <- genotyping %>%
  mutate_at(vars(starts_with("AX")), funs(as.integer(as.character(.)))) %>%
  unite(SNP, starts_with("AX"), sep="")%>%
  dplyr::select(ID, SNP) 








cat("\n\n OUPUT : genotyping data for BLUPF90 \n\n")
genotyping %>% dim()
print(nchar(genotyping[1,2]))
write.table(genotyping, titre_genotyping_blupf90, col.names = F, row.names = F, dec=".", sep=" ", quote=F)
# column 1 = LINE2 = modified ID of variety (string, 840 levels)
# column 2 = SNP data (0=homozygote recessiv, 1 = heteroyzgote, 2 = homozygote dominant, 5 = missing value) (string, 840 levels)
# dimmension of output : 840 lines * 2 columns

sessionInfo()