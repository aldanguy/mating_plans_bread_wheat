

suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(compiler))


simulate_QTL <- function(population, subset, variance_TBV, geno, genetic_map_raw){
  
  
  
  maf<- as.vector(unlist(apply(geno[,-1], 2, function(x) min(sum(x)/(length(x)*2), 1-sum(x)/(length(x)*2)))))

  
  genetic_map_raw <- genetic_map_raw %>% filter(population==!!population) %>%
    dplyr::select(chr, region, pos, marker, dcum) %>%
    arrange(chr, pos, marker) %>%
    unique()
  
  
  if (subset =="all"){
    
    genetic_map_subset <- genetic_map_raw 
    
  } else if  (subset == "chr") {
    

    
    genetic_map_subset <- genetic_map_raw %>% 
      mutate(maf=maf) %>%
      filter(maf >=0.1) %>%
      group_by(chr) %>% 
      mutate(n=1:n()) %>%
      mutate(random=sample(1:n(), size=1, replace=F)) %>%
      filter(n==random) %>%
      ungroup()
    
  } else if (grepl("mb", subset)) {
    
    mb <- as.numeric(gsub("mb","", subset))
    
    
    genetic_map_subset <- genetic_map_raw %>%
      mutate(maf=maf) %>%
      filter(maf >=0.1) %>%
      mutate(pos=pos/1e6) %>%
      mutate(segment=plyr::round_any(pos, mb))%>%
      group_by(chr, segment) %>%
      slice(n=sample(1:n(), size=1, replace=F)) %>%
      ungroup() 
    
    
  } else if (grepl("rand", subset)) {
    
    
    nrandom <- as.numeric(gsub("rand","", subset))
    
    genetic_map_subset <- genetic_map_raw %>%
      mutate(maf=maf) %>%
      filter(maf >=0.1) %>%
      slice(sample(1:n(),size=nrandom, replace = F ))

    
    
  } else if (grepl("cm",subset)) {
    
    cM <- as.numeric(gsub("cm","", subset))
    
    

    genetic_map_subset <- genetic_map_raw %>%
      mutate(maf=maf) %>%
      filter(maf >=0.1) %>%
      mutate(segment=plyr::round_any(dcum, cM)) %>%
      group_by(chr, segment) %>%
      slice(n=sample(1:n(), size=1, replace=F)) %>%
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