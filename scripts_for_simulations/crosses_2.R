

# Goal : Produce a standardized map for each population to compute variance-covariance matrix of progeny genotype
# Input : recombination profiles of several populations
# Output : standardized genetic map for each pop



Sys.time()
cat("\n\ncrosses.R\n\n")
rm(list = ls())
graphics.off()
set.seed(1)

suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(compiler))
suppressPackageStartupMessages(library(readr))



variables <- commandArgs(trailingOnly=TRUE)
cat("\n\nVariables : \n")
print(variables)
cat("\n\n")



titre_variance_crosses_input <- variables[1]
titre_lines_input <- variables[2]
titre_selection_intensity_input <- variables[3]
titre_function_calcul_index_variance_crosses <- variables[4]
selection_treshold <- as.numeric(variables[5])
selection_rate <- as.numeric(variables[6])
titre_crosses_output <- variables[7]
type <- variables[8]
population_variance <- variables[9]


# titre_variance_crosses_input <-  "/work2/genphyse/dynagen/adanguy/croisements/050321/value_crosses/crosses/variance_crosses_g1_simTRUE_20cm_r1_WE.txt"
# titre_lines_input <- "/work2/genphyse/dynagen/adanguy/croisements/050321/value_crosses/lines_estimated_simTRUE_20cm_r1.txt"               
# titre_selection_intensity_input <- "/work2/genphyse/dynagen/adanguy/croisements/050321/prepare/selection_intensity.txt"                                 
# titre_function_calcul_index_variance_crosses <- "/work/adanguy/these/croisements/scripts/calcul_index_variance_crosses.R"                                            
# selection_treshold <- 7.44181110537683                                                                                                   
# selection_rate <-  0.07                                                                                                               
# titre_crosses_output <-  "/work2/genphyse/dynagen/adanguy/croisements/050321/value_crosses/crosses/crosses_g1_simTRUE_20cm_r1_WE.txt"         
# generation <-1       





cat("\n\n INPUT : variance crosses \n\n")
variance_crosses <- fread(titre_variance_crosses_input)
variance_crosses %>% head()
variance_crosses %>% tail()
variance_crosses %>% dim()


cat("\n\n INPUT : lines info \n\n")
fread(titre_lines_input) %>% head()
fread(titre_lines_input) %>% tail()
fread(titre_lines_input) %>% dim()
lines <- fread(titre_lines_input)


cat("\n\n INPUT : selection intensity table \n\n")
selection_intensity <- fread(titre_selection_intensity_input)
selection_intensity %>% head()
selection_intensity%>% tail()
selection_intensity %>% dim()

source(titre_function_calcul_index_variance_crosses)


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


selection_intensity2=selection_intensity %>%
  filter(qij==!!selection_rate) %>%
  dplyr::select(int_qij) %>% 
  unlist() %>% as.vector()

selection_intensity3=selection_intensity %>%
  filter(qij==1e-4) %>%
  dplyr::select(int_qij) %>% 
  unlist() %>% as.vector()


lines2 <- lines  %>% arrange(ID) 
nind <- nrow(lines2)
nind

variance_crosses2 <- variance_crosses %>% arrange(P1, P2) %>%
  group_by(P1, P2, type, population_variance) %>%
  summarise(sd_RILs=sqrt(sum(variance_RILs)),
            sd_HDs=sqrt(sum(variance_HDs))) %>%
  ungroup()

lines_to_keep <- calcul1(nind)


# mean of progeny GEBV
u <- matrix(outer(lines2[,"value"], lines2[,"value"], "+")/2, ncol=1)
u <- u[lines_to_keep]
rm(lines, lines2, lines_to_keep)


crosses <- variance_crosses2 %>% mutate(gebv=u) %>%
  rowwise() %>%
  mutate(logw_RILs=log10(pnorm(selection_treshold, gebv, sd_RILs))) %>%
  mutate(uc_RILs=gebv+selection_intensity2*sd_RILs) %>%
  mutate(uc_extreme_RILs=gebv + selection_intensity3*sd_RILs) %>% 
  mutate(logw_HDs=log10(pnorm(selection_treshold, gebv, sd_HDs))) %>%
  mutate(uc_HDs=gebv+selection_intensity2*sd_HDs) %>%
  mutate(uc_extreme_HDs=gebv + selection_intensity3*sd_HDs) %>% 
  arrange(P1, P2) %>%
  mutate(sim=!!sim) %>%
  mutate(qtls=!!qtls) %>%
  mutate(h=!!h) %>%
  mutate(r=!!r) %>%
  mutate(g=!!g) %>%
  mutate(population_variance=!!population_variance) %>%
  mutate(type=!!etat) %>%
  dplyr::select(P1, P2, type, sim, qtls, h, r, g, population_variance, gebv, 
                sd_RILs, 
                sd_HDs, 
                logw_RILs, 
                logw_HDs, 
                uc_RILs, 
                uc_HDs, 
                
                uc_extreme_RILs,
                uc_extreme_HDs) %>%
  ungroup() %>%
  as.data.frame()




rm(variance_crosses, u)





cat("\n\nOUTPUT : variance of crosses and other performances \n\n")
head(crosses)
tail(crosses)
dim(crosses)
write_delim(crosses, titre_crosses_output, col_names = T, delim="\t", append = F, na="NA", quote_escape="none")




sessionInfo()
