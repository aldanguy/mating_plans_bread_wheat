

# Goal : simulate progeny genotypes
# Input : genotypes of inbred parental lines and number of progenies per cross
# Output : genotypes of progenies


# To install MOBPS
# install.packages("miraculix", configure.args="CXX_FLAGS=-march=native")



Sys.time()
cat("\n\ntbv_progenies.R\n\n")
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
titre_markers_input <- variables[2]
generation <- as.numeric(variables[3])
type <-  variables[4]
population<- variables[5]
critere <- variables[6]
affixe <- variables[7]
rr <- as.numeric(variables[8])
titre_lines_input <- variables[9]
titre_lines_output <- variables[10]

# [1] "/work2/genphyse/dynagen/adanguy/croisements/050321/best_crosses/genotypes/genotypes_g2_simTRUE_allcm_r2_WE_logw_real_rr1.txt"
# [2] "/work2/genphyse/dynagen/adanguy/croisements/050321/value_crosses/markers_estimated_simTRUE_allcm_r2_WE.txt"                  
# [3] "2"                                                                                                                           
# [4] "marker_simTRUE_allcm_r2"                                                                                                     
# [5] "WE"                                                                                                                          
# [6] "logw"                                                                                                                        
# [7] "real"                                                                                                                        
# [8] "1"                                                                                                                           
# [9] "/work2/genphyse/dynagen/adanguy/croisements/050321/best_crosses/lines/lines_g2_simTRUE_allcm_r2_WE_logw_real_rr1.txt" 



if (grepl("_h", type) ){
  

cat("\n\n INPUT : markers info \n\n ")
m2 <- fread(titre_markers_input)
head(m2) %>% print()
tail(m2) %>% print()
dim(m2) %>% print()


cat("\n\n INPUT : lines info \n\n ")
fread(titre_lines_input) %>% head() %>% print()
fread(titre_lines_input) %>% tail() %>% print()
fread(titre_lines_input) %>% dim() %>% print()



cat("\n\n INPUT : genotyping \n\n")
geno2 <- fread(titre_genotyping_input) 
geno2%>% select(1:10) %>% slice(1:10) %>% print()
geno2 %>% select(1:10) %>% slice((nrow(.)-10):nrow(.)) %>% print()
geno2 %>% dim() %>% print()





geno2 <- geno2 %>% filter(generation ==!!generation) %>% column_to_rownames("ID") %>% dplyr::select(starts_with("AX"))


tbv <- as.vector(unlist(apply(geno2, 1, function(x) sum(x*m2$value))))


lines <- data.frame(ID=rownames(geno2), used_as_parent=F, generation=generation, population=population, critere=critere, affixe=affixe, rr=rr, type=type, tbv=tbv) %>%
  dplyr::select(ID, generation, type, population, critere, affixe, rr, tbv, used_as_parent) %>%
  arrange(ID) %>% 
  inner_join(fread(titre_lines_input), by=c("ID","generation","type","population","critere", "affixe", "rr", "used_as_parent")) %>%
  rename(gebv=value) %>%
  dplyr::select(ID, generation, type, population, critere, affixe, rr, used_as_parent, gebv, tbv) %>%
  arrange(ID)

} else if (grepl("simFALSE", type) ){
  
  lines <- fread(titre_lines_input) %>%
    filter(generation==!!generation) %>%
    mutate(tbv=NA) %>%
    rename(gebv=value) %>%
    dplyr::select(ID, generation, type, population, critere, affixe, rr, used_as_parent, gebv, tbv) %>%
    arrange(ID)
  
} else {
  
  
  lines <- fread(titre_lines_input) %>%
    filter(generation==!!generation) %>%
    mutate(gebv=NA) %>%
    rename(tbv=value) %>%
    dplyr::select(ID, generation, type, population, critere, affixe, rr, used_as_parent, gebv, tbv) %>%
    arrange(ID)
}

cat("\n\n OUTPUT : lines info \n\n ")
head(lines)
tail(lines)
dim(lines)
write.table(lines, titre_lines_output, col.names=T, row.names=F, dec=".", sep="\t", quote=F)

sessionInfo()