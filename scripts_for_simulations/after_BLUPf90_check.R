



# Goal : gather data
# Input : blupf90 outputs, gebv and snp effects
# Output : files updated



Sys.time()
cat("\n\nafter_blupf90_check.R\n\n")
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
titre_lines_input <- variables[2]
titre_lines_output <- variables[3]


# titre_gebv_input <-  "/work2/genphyse/dynagen/adanguy/croisements/110222/real_data_GBLUP/gblup/raw/SNP_predictions_real_data_GBLUP.txt"
# titre_snp_effects_input <-  "/work2/genphyse/dynagen/adanguy/croisements/110222/real_data_GBLUP/gblup/raw/snp_sol_real_data_GBLUP.txt"        
# titre_lines_input <-"/work2/genphyse/dynagen/adanguy/croisements/110222/real_data_GBLUP/parents/phenotypes_real_data_GBLUP.txt"                         
# titre_markers_input <- "/work2/genphyse/dynagen/adanguy/croisements/110222/prepare/markers_WE.txt"                                       
# titre_markers_output <-  "/work2/genphyse/dynagen/adanguy/croisements/110222/real_data_GBLUP/gblup/markers_estimated_real_data_GBLUP.txt"  
# titre_lines_output <-  "/work2/genphyse/dynagen/adanguy/croisements/110222/real_data_GBLUP/gblup/gebv_parents_real_data_GBLUP.txt"       
# 






cat("\n\n INPUT : gebv \n\n")
gebv <- fread(titre_gebv_input) 
head(gebv)
tail(gebv)
dim(gebv)




cat("\n\n INPUT : lines info \n\n")
lines <- fread(titre_lines_input) 
head(lines)
tail(lines)
dim(lines)








lines2 <- lines  %>%
  dplyr::select(-one_of("value", "info", "P1","P2")) %>%
  inner_join(gebv %>% rename(ID=V1, value=V3) %>%
               dplyr::select(-V2), by="ID") %>%
  mutate(info="GEBV") %>%
  mutate(genomic="GBLUP") %>%
  arrange(ID) %>%
  dplyr::select(ID, value, info, everything())


    

##########################


cat("\n\n OUTPUT : lines info\n\n")
head(lines2)
tail(lines2)
dim(lines2)
write.table(lines2, titre_lines_output, col.names = T, row.names = F, dec=".", sep="\t", quote=F)






sessionInfo()