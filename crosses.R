

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



titre_variance_crosses <- variables[1]
titre_lines <- variables[2]
titre_selection_intensity <- variables[3]
titre_function_calcul_index_variance_crosses <- variables[4]
selection_treshold <- as.numeric(variables[5])
selection_rate <- as.numeric(variables[6])
titre_crosses <- variables[7]


# titre_variance_crosses <-  "/work2/genphyse/dynagen/adanguy/croisements/150221/value_crosses/variance_crosses_marker_simFALSE_10cm_WE.txt"
# titre_lines <-"/work2/genphyse/dynagen/adanguy/croisements/150221/value_crosses/lines_filtered_estimated.txt"                 
# titre_selection_intensity <- "/work2/genphyse/dynagen/adanguy/croisements/150221/prepare/selection_intensity.txt"   
# titre_function_calcul_index_variance_crosses <-  "/work/adanguy/these/croisements/scripts/calcul_index_variance_crosses.R"              
# selection_treshold <-  8.0307627                                                                       
# selection_rate <- 0.07                                                                                
# titre_crosses <-"/work2/genphyse/dynagen/adanguy/croisements/150221/value_crosses/crosses.txt"



cat("\n\n INPUT : variance crosses \n\n")
variance_crosses <- fread(titre_variance_crosses)
head(variance_crosses)
dim(variance_crosses)


cat("\n\n INPUT : info lines \n\n")
lines <- fread(titre_lines)
head(lines)
dim(lines)

cat("\n\n INPUT : selection intensity table \n\n")
selection_intensity <- fread(titre_selection_intensity)
head(selection_intensity)
dim(selection_intensity)

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


type=unique(variance_crosses$type)


if (length(grep("h", type))==0 & length(grep("TRUE", type)) > 0){
  
  sim=extraction(type, "_", 2)
  subset=extraction(type, "_", 3)
  r=extraction(type, "_", 4)
  type2=paste0("tbv_",sim,"_",subset,"_",r)
  
  
} else if (length(grep("h", type))==0 & length(grep("TRUE", type)) == 0){
  
  sim=extraction(type, "_", 2)
  subset=extraction(type, "_", 3)
  type2=paste0("gebv_",sim,"_",subset)
  
  
} else {
  
  sim=extraction(type, "_", 2)
  subset=extraction(type, "_", 3)
  h=extraction(type, "_", 4)
  r=extraction(type, "_", 5)
  type2=paste0("tbv_",sim,"_",subset,"_",h,"_",r)
  
  
}

lines2 <- lines %>% filter(used_as_parent==T & generation==0 & type==!!type2) %>% arrange(ID) 
nind <- nrow(lines2)


variance_crosses2 <- variance_crosses %>% arrange(P1, P2) %>%
  group_by(P1, P2, type) %>%
  summarise(sd=sqrt(sum(sd))) %>%
  ungroup()

lines_to_keep <- calcul1(nind)


# mean of progeny GEBV
u <- matrix(outer(lines2[,"value"], lines2[,"value"], "+")/2, ncol=1)
u <- u[lines_to_keep]
rm(lines, lines2, lines_to_keep)


variance_crosses2 <- variance_crosses2 %>% mutate(u=u) %>%
  arrange(P1, P2)




rm(variance_crosses, u)





cat("\n\nOUTPUT : variance of crosses and other performances \n\n")
head(variance_crosses2)
dim(variance_crosses2)
write_delim(variance_crosses2, titre_crosses, col_names = T, delim="\t", append = F, na="NA", quote_escape="none")




sessionInfo()
