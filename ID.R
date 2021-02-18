



# Goal : give a new ID to variety
# Input : ID of varieties
# Output : correspondance between old and new ID



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



titre_phenotypes <- variables[1]
titre_genotyping_matrix_raw <- variables[2]
titre_lines <- variables[3]
titre_pedigree <- variables[4]

# titre_phenotypes <- "/work/adanguy/these/croisements/amont/Traitees_IS.txt"
# titre_genotyping_matrix_raw <- "/work/adanguy/these/croisements/amont/matrix_nonimput_withoutOTV_names.txt"
# titre_lines <- "/work/adanguy/these/croisements/180120/lines.txt"

cat("\n\n INPUT : phenotypes \n\n")
phenotypes <- fread(titre_phenotypes)
head(phenotypes)
dim(phenotypes)
# column 1 = Geno = ID of variety (string, as many levels as number of variety, here 1 912)
# column 2 = LINE = ID of variety (string, here 1 909)
# column 9 = Yield = yield (numeric, units ?)
# column 10 = Prot = proteine content ? (numeric, units ?)
# column 11 = Env = Environnement ID (product of column 3 Year and column 4 Site) (string, 145 levels)
# column 3-8 : no importance here
# dimension of file : 63 301 * 11
# phenotypes %>% dplyr::select(LINE) %>% unique() %>% unlist() %>% as.vector() %>% length()



cat("\n\n INPUT : genotyping matrix to have markers ID \n\n")
genotyping <- suppressWarnings(fread(titre_genotyping_matrix_raw))
genotyping[1:10, 1:10]
dim(genotyping)
# subsampling of data for trials
# genotyping <- genotyping[,sort(c(1, sample(1:ncol(genotyping), size=2000, replace=F)))] 
# genotyping <- replace(genotyping, is.na(genotyping), 0)
# column 1 = V1 = variery ID (string, as many levels as the row number, here 2 143)
# column 2 - 31 315 = AX.1234567 = marker ID (intergers), here 31 315 markers
# dimension of file : 2 143 * 31315
# Don't worry with warning message


liste_lines_phenotypes <- unique(phenotypes$LINE)
liste_lines_genotyping_matrix <- suppressWarnings(fread(titre_genotyping_matrix_raw, select=1)) %>% unlist() %>% as.vector()
liste_lines <- intersect(liste_lines_phenotypes, liste_lines_genotyping_matrix)

lines <- data.frame(LINE=unique(c(liste_lines_phenotypes, liste_lines_genotyping_matrix))) %>%
  mutate(LINE=as.character(LINE)) %>%
  arrange(LINE) %>%
  mutate(line2=paste0(LINE,"_XXX")) %>%
  mutate(line2=gsub("\\s", "0", format(line2, width=max(nchar(line2))))) %>%
  arrange(line2) %>%
  mutate(phenotyped = LINE %in% liste_lines_phenotypes) %>%
  mutate(blue=NA) %>%
  mutate(gebv=NA) %>%
  mutate(genotyped = LINE %in% liste_lines_genotyping_matrix) %>%
  mutate(used_as_parent=NA) %>%
  mutate(generation=0) %>%
  mutate(best_crosses=NA) %>%
  mutate(run=NA)


pedigree <- data.frame(ID=lines$line2, P1=NA, P2=NA, generation=0)



cat("\n\n OUTPUT : correspondance between true ID and modified ID of lines \n\n")
head(lines)
dim(lines)
write.table(lines, titre_lines, col.names = T, row.names = F, dec=".", sep="\t", quote=F)
# column 1 = LINE = ID of variety (string, 3 185 levels = as many as varieties ID)
# column 2 = line2 = modified ID of variety (use in further analysis) (string, 3 185 levels)
# column 3 = phenotyped = variety phenotyped  (logical)
# column 4 = blue = estimate of variety yield (numeric, but NA for now)
# column 5 = gebv = estimate of variety yield after PG (numeric, but NA for now)
# column 6 = genotyped = variety was genotyped (logical)
# column 7 = used_as_parent = variety used as parent (logical, but NA for now)
# dim file : 3185*6



cat("\n\n OUTPUT : correspondance between true ID and modified ID of lines \n\n")
head(pedigree)
dim(pedigree)
write.table(pedigree, titre_pedigree, col.names = T, row.names = F, dec=".", sep="\t", quote=F)
# column 1 = LINE = ID of variety (string, 3 185 levels = as many as varieties ID)
# column 2 = line2 = modified ID of variety (use in further analysis) (string, 3 185 levels)
# column 3 = phenotyped = variety phenotyped  (logical)
# column 4 = blue = estimate of variety yield (numeric, but NA for now)
# column 5 = gebv = estimate of variety yield after PG (numeric, but NA for now)
# column 6 = genotyped = variety was genotyped (logical)
# column 7 = used_as_parent = variety used as parent (logical, but NA for now)
# dim file : 3185*6

sessionInfo()