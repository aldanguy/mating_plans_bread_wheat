



# Goal : gather data
# Input : blupf90 outputs, gebv and snp effects
# Output : files updated



Sys.time()
cat("\n\nafter_blupf90_2.R\n\n")
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

titre_predictions_input <- variables[1]
titre_pedigree_input <- variables[2]
type <- variables[3]
population_variance <- variables[4]
population_profile <- variables[5]
critere <- variables[6]
programme <-variables[7]
rr <- variables[8]
titre_lines_output <- variables[9]
progeny <- variables[10]


# titre_lines <- "/work/adanguy/these/croisements/180121/lines.txt"    
# titre_predictions <- "/work/adanguy/these/croisements/050221/sd_predictions/SNP_predictions"
# generation <- 1
# critere <- "gebv"

cat("\n\n INPUT : predictions of BV \n\n")
pred <- fread(titre_predictions_input)
head(pred)
tail(pred)
dim(pred)

cat("\n\n INPUT : pedigree info \n\n")
pedigree <- fread(titre_pedigree_input)
head(pedigree)
tail(pedigree)
dim(pedigree)


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

pred2 <- pred %>% rename(ID=V1, value=V3) %>%
  mutate(type=!!etat, 
         sim=!!sim,
         qtls=!!qtls,
         h=!!h,
         r=!!r,
         rr=!!rr,
         g=!!g,
         population_variance=!!population_variance,
         population_profile=!!population_profile,
         critere=!!critere,
         programme=!!programme,
         progeny=!!progeny) %>%
  inner_join(fread(titre_pedigree_input) %>% dplyr::select(ID, P1, P2), by="ID") %>%
  arrange(ID) %>%
  dplyr::select(ID, P1, P2, type, sim, qtls, h, r, rr, g, population_variance, population_profile, critere, programme, progeny,value)


cat("\n\n OUTPUT : lines info")
head(pred2)
tail(pred2)
dim(pred2)
write_delim(pred2, titre_lines_output, delim = "\t", na = "NA", append = F,  col_names = F, quote_escape = "none")

sessionInfo()