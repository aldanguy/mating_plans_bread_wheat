



# Goal : gather data
# Input : blupf90 outputs, gebv and snp effects
# Output : files updated



Sys.time()
cat("\n\nafter_blupf90.R\n\n")
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



titre_gebv <- variables[1]
titre_snp_effects <- variables[2]
titre_lines <- variables[3]
titre_markers_filtered_subset <- variables[4]
titre_markers_filtered_subset_estimated <- variables[5]
subset <- variables[6]

# titre_gebv <- "/work2/genphyse/dynagen/adanguy/croisements/150221/value_crosses/SNP_predictions_parents.txt"          
# titre_snp_effects <- "/work2/genphyse/dynagen/adanguy/croisements/150221/value_crosses/snp_sol_parents.txt"                  
# titre_lines <- "/work2/genphyse/dynagen/adanguy/croisements/150221/prepare/lines.txt"                                  
# titre_markers_filtered_subset <-  "/work2/genphyse/dynagen/adanguy/croisements/150221/value_crosses/markers_filtered_qtls.txt"          
# titre_markers_filtered_subset_estimated <-  "/work2/genphyse/dynagen/adanguy/croisements/150221/value_crosses/markers_filtered_subset_estimated.txt"
# subset <- "all"

cat("\n\n INPUT : gebv \n\n")
gebv <- fread(titre_gebv)
head(gebv)
dim(gebv)



cat("\n\n INPUT : snp effects \n\n")
snp_effects <- fread(titre_snp_effects)
head(snp_effects)
dim(snp_effects)

cat("\n\n INPUT : lines info \n\n")
lines <- fread(titre_lines)
head(lines)
dim(lines)

cat("\n\n INPUT : lines info \n\n")
markers <- fread(titre_markers_filtered_subset)
head(markers)
dim(markers)





snp_effects2 <- snp_effects %>% dplyr::select(chr, pos, snp_effect)%>%
  full_join(markers %>% mutate(chr2=as.numeric(as.factor(chr))), by=c("chr"="chr2", "pos"="pos")) %>%
  dplyr::select(chr.y, region, pos, marker, dcum_WE, dcum_EE, dcum_WA, dcum_EA, dcum_CsRe, snp_effect) %>%
  rename(chr=chr.y) %>%
  arrange(chr, pos) %>%
  mutate(snp_effect=ifelse(is.na(snp_effect), 0, snp_effect)) %>%
  rename(!!paste0("qb_",subset,"cm"):=snp_effect)




lines2 <- lines %>% dplyr::select(-one_of("gebv", paste0("gebv_qb_",subset,"cm"))) %>%
  full_join(gebv %>% rename(line2=V1, gebv=V3) %>% dplyr::select(-V2), by="line2") %>%
  rename(!!paste0("gebv_qb_",subset,"cm"):=gebv) %>%
  arrange(line2)



##########################


cat("\n\n OUTPUT : correspondance between true ID and modified ID of lines \n\n")
tail(lines)
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




cat("\n\n OUTPUT : markers with markers effects \n\n")
head(snp_effects2)
dim(snp_effects2)
write.table(snp_effects2, titre_markers_filtered_subset_estimated, col.names = T, row.names = F, dec=".", sep="\t", quote=F)

sessionInfo()