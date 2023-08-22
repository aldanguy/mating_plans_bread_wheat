



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



titre_gebv_input <- variables[1]
titre_snp_effects_input <- variables[2]
titre_lines_input <- variables[3]
titre_markers_input <- variables[4]
titre_markers_output <- variables[5]
titre_lines_output <- variables[6]
type <- variables[7]



  # titre_gebv <- "/work2/genphyse/dynagen/adanguy/croisements/150221/value_crosses/blupf90/simFALSE/10cm/SNP_predictions_simFALSE_10cm.txt"
  # titre_snp_effects <-  "/work2/genphyse/dynagen/adanguy/croisements/150221/value_crosses/blupf90/simFALSE/10cm/snp_sol_simFALSE_10cm.txt"        
  # titre_lines <-  "/work2/genphyse/dynagen/adanguy/croisements/150221/prepare/lines.txt"                                                    
  # titre_markers_filtered_subset <- "/work2/genphyse/dynagen/adanguy/croisements/150221/prepare/markers_filtered.txt"                                         
  # titre_markers_filtered_subset_estimated <- "/work2/genphyse/dynagen/adanguy/croisements/150221/value_crosses/blupf90/simFALSE/10cm/markers_simFALSE_10cm.txt"        
  # titre_lines_estimated <- "/work2/genphyse/dynagen/adanguy/croisements/150221/value_crosses/blupf90/simFALSE/10cm/lines_simFALSE_10cm.txt"          
  # type <-  "simFALSE_10cm"  
 
cat("\n\n INPUT : gebv \n\n")
fread(titre_gebv_input) %>% head()
fread(titre_gebv_input) %>% tail()
fread(titre_gebv_input) %>% dim()
l <- fread(titre_gebv_input)
head(l)


# cat("\n\n INPUT : snp effects \n\n")
# fread(titre_snp_effects_input) %>% head()
# fread(titre_snp_effects_input) %>% tail()
# fread(titre_snp_effects_input) %>% dim()


cat("\n\n INPUT : lines info \n\n")
fread(titre_lines_input) %>% arrange(ID, type) %>% head()
fread(titre_lines_input) %>% arrange(ID, type) %>% tail()
fread(titre_lines_input) %>% arrange(ID, type)  %>% filter(used_as_parent==T & phenotyped==T) %>% head()
fread(titre_lines_input) %>% dim()



# cat("\n\n INPUT : lines info \n\n")
# fread(titre_markers_input) %>% head()
# fread(titre_markers_input) %>% tail()
# fread(titre_markers_input) %>% dim()
# 

# 
# 
# snp_effects2 <- fread(titre_snp_effects_input) %>%
#   rename(chr2=chr) %>%
#   rename(value=snp_effect) %>%
#   dplyr::select(chr2, pos, value)%>%
#   full_join(fread(titre_markers_input) %>%
#               arrange(chr, pos, marker, population)%>%
#               dplyr::select(-one_of("value", 'type')) %>%
#               mutate(chr2=as.numeric(as.factor(chr))) , 
#             by=c("chr2", "pos")) %>%
#   dplyr::select(-chr2)%>%
#   mutate(value=ifelse(is.na(value), 0, value)) %>%
#   mutate(type=type)  %>%
#   arrange(chr, pos, marker, population) %>%
#   dplyr::select(one_of(colnames(fread(titre_markers_input) %>%
#                                         dplyr::select(-one_of("value", 'type'))), "type", "value"))





lines2 <- fread(titre_lines_input)  %>%
  dplyr::select(-one_of("value", "type")) %>%
  cbind(., l %>% rename(value=solution) %>% dplyr::select(value)) %>%
  mutate(type=paste0("gebv_",type))%>%
  mutate(type=gsub("marker_","", type)) %>%
  arrange(ID) %>%
  dplyr::select(one_of(colnames(fread(titre_lines_input) %>%
                                  dplyr::select(-one_of("value", 'type'))), "type", "value"))



##########################


cat("\n\n OUTPUT : lines info\n\n")
head(lines2)
tail(lines2)
lines2 %>% filter(used_as_parent==T & phenotyped==T) %>% head()
dim(lines2)
write.table(lines2, titre_lines_output, col.names = T, row.names = F, dec=".", sep="\t", quote=F)
# column 1 = LINE = ID of variety (string, 3 185 levels = as many as varieties ID)
# column 2 = line2 = modified ID of variety (use in further analysis) (string, 3 185 levels)
# column 3 = phenotyped = variety phenotyped  (logical)
# column 4 = blue = estimate of variety yield (numeric, but NA for now)
# column 5 = gebv = estimate of variety yield after PG (numeric, but NA for now)
# column 6 = genotyped = variety was genotyped (logical)
# column 7 = used_as_parent = variety used as parent (logical, but NA for now)
# dim file : 3185*6



# 
# cat("\n\n OUTPUT : markers with markers effects \n\n")
# head(snp_effects2)
# tail(snp_effects2)
# dim(snp_effects2)
# write.table(snp_effects2, titre_markers_output, col.names = T, row.names = F, dec=".", sep="\t", quote=F)

sessionInfo()