

suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(compiler))


simulate_QTL <- function(population, cM, variance_TBV, geno, genetic_map_raw){
  
  
  
  

  
  genetic_map_raw <- genetic_map_raw %>% filter(population==!!population) %>%
    dplyr::select(chr, region, pos, marker, dcum) %>%
    arrange(chr, pos, marker) %>%
    unique()
  cM <- gsub("cm","", cM)
  
  
  if (cM =="all"){
    
    genetic_map_subset <- genetic_map_raw 
    
  } else if  (cM == "chr") {
    

    
    genetic_map_subset <- genetic_map_raw %>% 
      group_by(chr) %>% 
      mutate(n=1:n()) %>%
      mutate(random=sample(1:n(), size=1, replace=F)) %>%
      filter(n==random) %>%
      ungroup()
    
    
    
  } else {
    
    cM = as.numeric(cM)
    
    genetic_map_subset <- genetic_map_raw %>%
      mutate(segment=plyr::round_any(dcum, cM)) %>%
      group_by(chr, segment) %>%
      dplyr::mutate(n=rep(1:n())) %>%
      filter(n==n()) %>%
      ungroup() 
    
  }
  
  markers_to_keep <- genetic_map_subset$marker
  
  
  simulated_QTL <- rnorm(n=length(markers_to_keep), m=0, sd=1)
  
  geno2 <- geno %>% dplyr::select(one_of(markers_to_keep))
  
  var_obs <- var(crossprod(t(geno2), as.matrix(simulated_QTL)))
  
  lambda=sqrt(variance_TBV/var_obs)
  
  simulated_QTL2 <- simulated_QTL*c(lambda)
  
  
  # var_obs2 <- var(crossprod(t(geno2), as.matrix(simulated_QTL2))) should be qual to variance_TBV
  
  
  genetic_map_output <- genetic_map_subset %>% 
    mutate(simulated_snp_effect=simulated_QTL2) %>%
    dplyr::select(marker, simulated_snp_effect)%>%
    full_join(genetic_map_raw, by="marker") %>%
    dplyr::select(chr, region, pos, marker, simulated_snp_effect) %>%
    mutate(simulated_snp_effect=ifelse(is.na(simulated_snp_effect),0,simulated_snp_effect)) %>%
    arrange(chr, pos)
  
  
  
  return(genetic_map_output$simulated_snp_effect)
  
}