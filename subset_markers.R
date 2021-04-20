subset_genetic_map <- function(genetic_map_raw, population, cM){
  
  

  genetic_map_raw <- genetic_map_raw %>% filter(population==!!population) %>% arrange(chr, pos, marker, population)
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
  
  return(genetic_map_subset)
  
}