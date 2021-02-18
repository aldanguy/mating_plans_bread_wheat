

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



titre_markers <- variables[1]
titre_genotyping_matrix <- variables[2]
titre_lines <- variables[3]
population <- variables[4]
nbrun <- as.numeric(variables[5])
subset <- variables[6]
titre_markers_output <- variables[7]
titre_lines_output <- variables[8]

# titre_markers <- "/work2/genphyse/dynagen/adanguy/croisements/150221/prepare/markers_filtered.txt"                  
# titre_genotyping_matrix <- "/work2/genphyse/dynagen/adanguy/croisements/150221/prepare/genotyping_matrix_filtered_imputed.txt"
# titre_lines <- "/work2/genphyse/dynagen/adanguy/croisements/150221/prepare/lines.txt"                             
# population <-  "WE"                                                                                               
# nbrun <-3                                                                                               
# subset <-  "all"                                                                                              
# titre_output <- "/work2/genphyse/dynagen/adanguy/croisements/150221/value_crosses/markers_filtered_qtls_all.txt" 

cat("\n\n INPUT : markers with physical position \n\n")
markers <- fread(titre_markers)
head(markers)
dim(markers)
# column 1 = chr = chr ID with letters (string, 21 levels)
# column 2 = region = ID of chr region (string, 5 levels R1, R2a, C, R2b, R3)
# column 3 = pos = physical position of marker (intergers, units bp)
# column 4 = marker = marker ID (string, as many levels as number of markers, here 21 196)
# column 5 = dcum = cumulated genetic distance since chromosome start (numeric, units = cM)

cat("\n\n INPUT : markers with physical position \n\n")
lines <- fread(titre_lines)
head(lines)
dim(lines)


cat("\n\n INPUT : gentyping matrix updated \n\n")
geno <- fread(titre_genotyping_matrix)
geno[1:10,1:10]
# column 1 = LINE2 = modified ID for variety (string, 840 levels)
# column 2 - 19751 = genotype at each SNP
# dimension: 840 * 19 751


variance_TBV <- lines %>% filter(used_as_parent==T) %>%
  summarise(v=var(gebv)) %>%
  unlist() %>%
  as.vector()


#rm(haplo_1, haplo_2)


genetic_map_raw <- fread(titre_markers) %>%
  arrange(chr, pos)


genetic_map2 <- genetic_map_raw

cM="all"
simulate_QTL <- function(population, cM, variance_TBV, geno, genetic_map_raw){
  
  
  
  
  colonne_genetic_map_raw <- colnames(genetic_map_raw)[grep(population,colnames(genetic_map_raw))]
  genetic_map_raw[,"dcum"] <- genetic_map_raw[,colonne_genetic_map_raw]/1e2
  
  if (cM !="all"){
    
    cM = as.numeric(cM)
    
    genetic_map_subset <- genetic_map_raw %>%
      mutate(segment=plyr::round_any(dcum*1e2, cM))%>%
      group_by(chr, segment) %>%
      dplyr::mutate(n=rep(1:n())) %>%
      filter(n==n()) %>%
      ungroup() 
    
    
    
  } else {
    
    
    genetic_map_subset <- genetic_map_raw 
    
  }
  
  markers_to_keep <- genetic_map_subset$marker
  
  
  simulated_QTL <- rnorm(n=length(markers_to_keep), m=0, sd=1)
  
  geno2 <- geno %>% dplyr::select(one_of(markers_to_keep))
  
  var_obs <- var(crossprod(t(geno2), as.matrix(simulated_QTL)))
  
  lambda=sqrt(variance_TBV/var_obs)
  
  simulated_QTL2 <- simulated_QTL*c(lambda)
  
  
  # var_obs2 <- var(crossprod(t(geno2), as.matrix(simulated_QTL2))) should be qual to variance_TBV
  
  
  genetic_map_output <- genetic_map_subset %>% mutate(simulated_snp_effect=simulated_QTL2) %>%
    dplyr::select(marker, simulated_snp_effect)%>%
    full_join(genetic_map_raw, by="marker") %>%
    dplyr::select(chr, region, pos, marker, simulated_snp_effect) %>%
    mutate(simulated_snp_effect=ifelse(is.na(simulated_snp_effect),0,simulated_snp_effect)) %>%
    arrange(chr, pos)
  
  
  
  return(genetic_map_output$simulated_snp_effect)
  
}

for (i in 1:nbrun) {
  
  
  effects = simulate_QTL(variance_TBV=variance_TBV, cM=subset, population=population, geno = geno, genetic_map_raw =genetic_map_raw)
  
  genetic_map2 <- cbind(genetic_map2, effects=effects)
  
  colnames(genetic_map2) <- c(colnames(genetic_map2)[-ncol(genetic_map2)], paste0("qs_",subset,"cm_",i))
  
  
  parental_gebv <- data.frame(line2=geno[,1], parental_gebv=crossprod(t(geno[,-1]), as.matrix(effects)))
  
  lines <- lines %>% dplyr::select(-one_of('gebv', paste0("gebv_qs_",subset,"cm_",i))) %>%
    full_join(parental_gebv, by="line2") %>%
    rename(!!paste0("gebv_qs_",subset,"cm"):=parental_gebv) %>%
    arrange(line2)
    

}


genetic_map2 <- genetic_map2 %>%
  arrange(chr, pos)



head(genetic_map2)
dim(genetic_map2)
write.table(genetic_map2, titre_markers_output, col.names = T, row.names = F, dec=".", sep="\t", quote=F)



head(lines)
dim(lines)
write.table(lines, titre_lines_output, col.names = T, row.names = F, dec=".", sep="\t", quote=F)

sessionInfo()