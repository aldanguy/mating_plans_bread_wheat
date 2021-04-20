

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
generation <- as.numeric(variables[8])

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

selection_intensity2=selection_intensity %>%
  filter(qij==!!selection_rate) %>%
  dplyr::select(int_qij) %>% 
  unlist() %>% as.vector()

selection_intensity3=selection_intensity %>%
  filter(qij==1e-4) %>%
  dplyr::select(int_qij) %>% 
  unlist() %>% as.vector()


type=unique(variance_crosses$type)


if (length(grep("_h", type))==0 & length(grep("TRUE", type)) > 0){
  
  sim=extraction(type, "_", 2)
  subset=extraction(type, "_", 3)
  r=extraction(type, "_", 4)
  type2=paste0("tbv_",sim,"_",subset,"_",r)
  
  
} else if (length(grep("_h", type))==0 & length(grep("TRUE", type)) == 0){
  
  sim=extraction(type, "_", 2)
  subset=extraction(type, "_", 3)
  type2=paste0("gebv_",sim,"_",subset)
  
  
} else {
  
  sim=extraction(type, "_", 2)
  subset=extraction(type, "_", 3)
  h=extraction(type, "_", 4)
  r=extraction(type, "_", 5)
  type2=paste0("gebv_",sim,"_",subset,"_",h,"_",r)
  
  
}


if (grepl("_h", type) | grepl("simFALSE", type)){
  
  
  motif_line <- "gebv"
  
} else {
  
  motif_line <- "tbv"
  
}

lines2 <- lines %>% filter(used_as_parent==T & generation==!!generation & endsWith(type, type2)==T & grepl(motif_line, type)) %>% arrange(ID) 
nind <- nrow(lines2)
nind

variance_crosses2 <- variance_crosses %>% arrange(P1, P2) %>%
  group_by(P1, P2, generation, type, population) %>%
  summarise(sd=sqrt(sum(variance))) %>%
  ungroup()

lines_to_keep <- calcul1(nind)


# mean of progeny GEBV
u <- matrix(outer(lines2[,"value"], lines2[,"value"], "+")/2, ncol=1)
u <- u[lines_to_keep]
rm(lines, lines2, lines_to_keep)


crosses <- variance_crosses2 %>% mutate(gebv=u) %>%
  rowwise() %>%
  mutate(logw=log10(pnorm(selection_treshold, gebv, sd))) %>%
  mutate(uc=gebv+selection_intensity2*sd) %>%
  mutate(uc_extreme=gebv + selection_intensity3*sd) %>% 
  arrange(P1, P2) %>%
  dplyr::select(P1, P2, generation, type, population, gebv, sd, logw, uc, uc_extreme) %>%
  ungroup() %>%
  as.data.frame()




rm(variance_crosses, u)





cat("\n\nOUTPUT : variance of crosses and other performances \n\n")
head(crosses)
tail(crosses)
dim(crosses)
write_delim(crosses, titre_crosses_output, col_names = T, delim="\t", append = F, na="NA", quote_escape="none")




sessionInfo()
