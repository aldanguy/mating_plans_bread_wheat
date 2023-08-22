

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
titre_pedigree_input <- variables[3]
type <-  variables[4]
critere<- variables[5]
programme <- variables[6]
rr <- variables[7]
population_variance <- variables[8]
population_profile <- variables[9]
titre_lines_output <- variables[10]
progeny <- variables[11]

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



cat("\n\n INPUT : pedigree info \n\n ")
fread(titre_pedigree_input) %>% head()
fread(titre_pedigree_input) %>% tail()
fread(titre_pedigree_input) %>% dim()






extraction <- function(string, character_split, number){
  
  out <- as.vector(unlist(strsplit(string, split=character_split)))
  
  if (number > length(out)){
    
    out <- NA
  } else {
    
    out <- out[number]
  }
  
  return(out)
  
}




sim=gsub("sim","",as.vector(unlist(strsplit(type, split="_")))[1])


if (sim == "FALSE"){
  
  g=gsub("g","",as.vector(unlist(strsplit(type, split="_")))[2])
  h=NA
  r=NA
  qtls=NA
  
  etat="estimated"
  
  
  
} else if (sim=="TRUE") {
  
  
  if (grepl("_h", type)){
    
    qtls=as.vector(unlist(strsplit(type, split="_")))[2]
    h=gsub("h","",as.vector(unlist(strsplit(type, split="_")))[3])
    r=paste0(as.vector(unlist(strsplit(type, split="_")))[4],"r")
    g=gsub("g","",as.vector(unlist(strsplit(type, split="_")))[5])
    etat="estimated"
    
    
    
    
  } else if (!grepl("_h", type)) {
    
    qtls=as.vector(unlist(strsplit(type, split="_")))[2]
    r=paste0(as.vector(unlist(strsplit(type, split="_")))[3],"r")
    h=NA
    g=NA
    etat="real"
    
    
    
  }
  
  
}





m2 <- fread(titre_markers_input) 


geno2 <- fread(titre_genotyping_input) %>% column_to_rownames("ID") %>% dplyr::select(starts_with("AX"))


tbv <- as.vector(unlist(apply(geno2, 1, function(x) sum(x*m2$value))))


lines <- data.frame(ID=rownames(geno2),
                    value=tbv,
                    type=etat,
                    sim=sim,
                    qtls=qtls,
                    h=h,
                    r=r,
                    rr=rr,
                    g=g,
                    population_variance=population_variance,
                    population_profile=population_profile,
                    critere=critere,
                    programme=programme,
                    progeny=progeny)  %>%
  inner_join(fread(titre_pedigree_input) %>% dplyr::select(ID, P1, P2), by="ID") %>%
  arrange(ID) %>%
  dplyr::select(ID, P1, P2, type, sim, qtls, h, r, rr, g, population_variance, population_profile, critere, programme, progeny,value)

cat("\n\n OUTPUT : lines info \n\n ")
head(lines)
tail(lines)
dim(lines)
write.table(lines, titre_lines_output, col.names=F, row.names=F, dec=".", sep="\t", quote=F)

sessionInfo()