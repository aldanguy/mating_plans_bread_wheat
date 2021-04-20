

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
titre_lines_output <- variables[9]

 # titre_genotyping_input <-  "/work2/genphyse/dynagen/adanguy/croisements/050321/best_crosses/g2_simTRUE_allcm_r2_WE/g2_simTRUE_allcm_r2_WE_logw_real/g2_simTRUE_allcm_r2_WE_logw_real_rr1/genotypes_g2_simTRUE_allcm_r2_WE_logw_real_rr1.txt"
 # titre_markers_input <-"/work2/genphyse/dynagen/adanguy/croisements/050321/value_crosses/markers_estimated.txt"                                                                                                                         
 # generation <- 2                                                                                                                                                                                                           
 # type <- "marker_simTRUE_allcm_r2"                                                                                                                                                                                        
 # population<- "WE"                                                                                                                                                                                                             
 # critere <-  "logw"                                                                                                                                                                                                           
 # affixe <-  "real"                                                                                                                                                                                                           
 # rr <- 1                                                                                                                                                                                                            
 # titre_lines_output <- "/work2/genphyse/dynagen/adanguy/croisements/050321/best_crosses/lines/lines_g2_simTRUE_allcm_r2_WE_logw_real_rr1.txt"                                                                                           
 # 
 
 
 





cat("\n\n INPUT : markers info \n\n ")
fread(titre_markers_input) %>% head()
fread(titre_markers_input) %>% tail()
fread(titre_markers_input) %>% dim()




cat("\n\n INPUT : genotyping \n\n")
fread(titre_genotyping_input) %>% select(1:10) %>% slice(1:10)
fread(titre_genotyping_input) %>% select(1:10) %>% slice((nrow(.)-10):nrow(.))
fread(titre_genotyping_input) %>% dim()



extraction <- function(string, character_split, number){
  
  out <- as.vector(unlist(strsplit(string, split=character_split)))
  
  if (number > length(out)){
    
    out <- NA
  } else {
    
    out <- out[number]
  }
  
  return(out)
  
}


pos=length(unlist(strsplit(type, split="_")))
r <- as.numeric(gsub("r","",extraction(type, "_", pos)))
subset <- extraction(type, "_", 3)


m2 <- fread(titre_markers_input) %>%
  filter(population==!!population) %>%
  filter(type == !!type) 


geno2 <- fread(titre_genotyping_input) %>% column_to_rownames("ID") %>% dplyr::select(starts_with("AX"))


tbv <- as.vector(unlist(apply(geno2, 1, function(x) sum(x*m2$value))))


lines <- data.frame(ID=rownames(geno2), used_as_parent=F, generation=generation, population=population, critere=critere, affixe=affixe, rr=rr, type=type, value=tbv) %>%
  dplyr::select(ID, generation, type, population, critere, affixe, rr, value, used_as_parent) %>%
  arrange(ID) 


cat("\n\n OUTPUT : lines info \n\n ")
head(lines)
tail(lines)
dim(lines)
write.table(lines, titre_lines_output, col.names=T, row.names=F, dec=".", sep="\t", quote=F)

sessionInfo()