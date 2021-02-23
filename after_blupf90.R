



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
titre_lines_estimated <- variables[6]
simulation <- variables[7]
subset <- variables[8]
run <- as.numeric(variables[9])
h2 <- as.numeric(variables[10])



 #  titre_gebv <- "/work2/genphyse/dynagen/adanguy/croisements/150221/value_crosses/blupf90/allcm/simFALSE/g0/r0/SNP_predictions_allcm_simFALSE_g0_r0.txt"
 #  titre_snp_effects <-  "/work2/genphyse/dynagen/adanguy/croisements/150221/value_crosses/blupf90/allcm/simFALSE/g0/r0/snp_sol_allcm_simFALSE_g0_r0.txt"        
 #  titre_lines <-  "/work2/genphyse/dynagen/adanguy/croisements/150221/prepare/lines.txt"                                                                  
 #  titre_markers_filtered_subset <-  "/work2/genphyse/dynagen/adanguy/croisements/150221/prepare/markers_filtered.txt"                                                       
 #  titre_markers_filtered_subset_estimated <- "/work2/genphyse/dynagen/adanguy/croisements/150221/value_crosses/blupf90/allcm/simFALSE/g0/r0/markers_allcm_simFALSE_g0_r0.txt"        
 #  subset <- "all"                                                                                                                                   
 #  generation <- "0"                                                                                                                                     
 #  run <-  "0"                                                                                                                                     
 #  simulation <- "FALSE"                                                                                                                                 
 #  titre_lines_estimated <-  "/work2/genphyse/dynagen/adanguy/croisements/150221/value_crosses/blupf90/allcm/simFALSE/g0/r0/lines_allcm_simFALSE_g0_r0.txt"  
 # h2 <- 0.25
 
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


if (simulation=="TRUE"){
  
  nom_mkrs=paste0("qe_",subset,"cm_h",h2,"_r",run)
  nom_gebv=paste0("gebv_qr_",subset,"cm_h",h2,"_r",run)
  motif_to_supress="gebv_qr"
  
} else if (simulation=="FALSE"){
  
  nom_mkrs=paste0("qb_",subset,"cm")
  nom_gebv=paste0("gebv_qb_",subset,"cm")
  motif_to_supress="gebv_qb_"
  
}


snp_effects2 <- snp_effects %>% dplyr::select(chr, pos, snp_effect)%>%
  full_join(markers %>% mutate(chr2=as.numeric(as.factor(chr))), by=c("chr"="chr2", "pos"="pos")) %>%
  dplyr::select(chr.y, region, pos, marker, dcum_WE, dcum_EE, dcum_WA, dcum_EA, dcum_CsRe, snp_effect, starts_with("qb"), starts_with("qr")) %>%
  rename(chr=chr.y) %>%
  arrange(chr, pos) %>%
  mutate(snp_effect=ifelse(is.na(snp_effect), 0, snp_effect)) %>%
  rename(!!nom_mkrs:=snp_effect)  %>%
  dplyr::select(everything(), starts_with("qb"), starts_with("qr"), starts_with("qe"))





lines2 <- lines %>% dplyr::select(-matches(motif_to_supress)) %>%
  full_join(gebv %>% rename(line2=V1, gebv=V3) %>% dplyr::select(-V2), by="line2") %>%
  rename(!!nom_gebv:=gebv) %>%
  arrange(line2) %>%
  dplyr::select(everything(), starts_with("tbv"), starts_with("gebv"), starts_with("blue"))




##########################


cat("\n\n OUTPUT : correspondance between true ID and modified ID of lines \n\n")
head(lines2)
tail(lines2)
dim(lines2)
write.table(lines2, titre_lines_estimated, col.names = T, row.names = F, dec=".", sep="\t", quote=F)
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