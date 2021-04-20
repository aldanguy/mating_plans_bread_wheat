

Sys.time()
cat("\n\nsimulate_QTL.R\n\n")
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



titre_markers_input <- variables[1]
titre_genotyping_input <- variables[2]
titre_lines_input <- variables[3]
population <- variables[4]
type <- variables[5]
titre_fonction_simulate_qtls <- variables[6]
titre_markers_output <- variables[7]
titre_lines_output <- variables[8]

# titre_markers_input <- "/work2/genphyse/dynagen/adanguy/croisements/050321/prepare/markers.txt"                                                                
# titre_genotyping_input <- "/work2/genphyse/dynagen/adanguy/croisements/050321/prepare/genotyping.txt"                                                             
# titre_lines_input <- "/work2/genphyse/dynagen/adanguy/croisements/050321/value_crosses/lines_estimated.txt"                                                  
# population <- "WE"                                                                                                                                    
# type <-"simTRUE_allcm_h0.8_r2"                                                                                                                 
# titre_fonction_simulate_qtls <-  "/work/adanguy/these/croisements/scripts/simulate_qtls_3.R"                                                                             

source(titre_fonction_simulate_qtls)

h2 <- as.numeric(gsub("h","",as.vector(unlist(strsplit(type, split = "_")))[3]))
subset=as.vector(unlist(strsplit(type, split = "_")))[2]
r=as.numeric(gsub("r","",as.vector(unlist(strsplit(type, split = "_")))[4]))
type_marker=paste0("marker_simTRUE_",subset,"_r",r)

set.seed(r)

cat("\n\n INPUT : markers info \n\n")
fread(titre_markers_input) %>% head()
fread(titre_markers_input) %>% tail()
fread(titre_markers_input) %>% dim()


cat("\n\n INPUT : lines info \n\n")
fread(titre_lines_input) %>% head()
fread(titre_lines_input) %>% tail()
fread(titre_lines_input) %>% dim()


cat("\n\n INPUT : genotyping data \n\n")
fread(titre_genotyping_input) %>% select(1:10) %>% slice(1:10)
fread(titre_genotyping_input) %>% select(1:10) %>% slice((nrow(.)-10):nrow(.))
fread(titre_genotyping_input)%>% dim()




TBV <- fread(titre_lines_input) %>%
  filter(used_as_parent==T & type=="gebv_simFALSE_allcm")%>%
  dplyr::select(value) %>%
  unlist() %>%
  as.vector() %>%
  na.omit()

variance_TBV=var(TBV, na.rm = T)
print(variance_TBV)


variance_env=(variance_TBV - h2)/h2

#rm(haplo_1, haplo_2)


lines2 <- fread(titre_lines_input) %>%
  dplyr::select(-value, -type) %>%
  unique() %>%
  arrange(ID)


genetic_map_raw <- fread(titre_markers_input) %>%
  filter(population==!!population) %>%
  arrange(chr, pos, marker, population) 




snp_effect = simulate_QTL(variance_TBV=variance_TBV, cM=subset, population=population, geno = fread(titre_genotyping_input), genetic_map_raw =genetic_map_raw)

genetic_map <- cbind( fread(titre_markers_input), value=rep(snp_effect, each=length(fread(titre_markers_input) %>% dplyr:::select(population) %>% unique() %>% unlist() %>% as.vector()))) %>%
  mutate(type=type_marker)%>%
  dplyr::select(one_of(colnames(genetic_map_raw), "type", "value"))
                


  

TBV=crossprod(t(fread(titre_genotyping_input)[,-1]), as.matrix(snp_effect))

parental_tbv <- data.frame(ID=fread(titre_genotyping_input)[,1],
                           type=paste0("tbv_",type),
                           value=TBV) %>%
  inner_join(lines2, by=c("ID"))%>%
  arrange(ID) %>%
  dplyr::select(one_of(colnames(fread(titre_lines_input) %>%
                                  dplyr::select(-one_of("value", 'type'))), "type", "value"))




parental_pheno <- data.frame(ID=fread(titre_genotyping_input)[,1],
                             type=paste0("pheno_",type),
                             value=TBV + rnorm(length(TBV), m=0, sd=sqrt(variance_env))) %>%
  inner_join(lines2, by=c("ID"))%>%
  arrange(ID) %>%
  dplyr::select(one_of(colnames(fread(titre_lines_input) %>%
                                  dplyr::select(-one_of("value", 'type'))), "type", "value"))




lines <- rbind(parental_tbv, parental_pheno) %>% arrange(ID, type)


cat("\n\n OUPUT : markers info \n\n")
head(genetic_map)
tail(genetic_map)
dim(genetic_map)
write.table(genetic_map, titre_markers_output, col.names = T, row.names = F, dec=".", sep="\t", quote=F)

cat("\n\n OUPUT : lines info \n\n")
head(lines)
tail(lines)
dim(lines)
write.table(lines, titre_lines_output, col.names = T, row.names = F, dec=".", sep="\t", quote=F)

sessionInfo()