
# Goal :   # some pairwise crosses has to be remove (self crosses, duplicated crosses). The index of crosses to remove follow a numeric series, modeled in calcul3()
# Such function allow to identify which crosses has to be kept
# Input : total number of individuals (nind), number of individuals to cross with all other (step), number of the step (i)
# Output : index of crosses to keep





# Pairwise crosses are goind to be compute per group. But some repetition from one group to another. Such function allow to discard repeated computations
calcul1 <- function(nind){
  
  to_supress <- as.numeric()
  
  same_line <- seq(0,nind*nind, nind)+1
  
  for (k in 1:nind){
    
    to_supress <- c(to_supress, seq(same_line[k], same_line[k]+(k-1), 1))
    
    
  }
  
  lignes <- c(1:(nind*nind))
  lignes <- lignes[-to_supress]
  
  
  return(lignes)
  
  
}

calcul2 <- function(nind, i, step){
  
  k=min(i,0)
  
  res=0
  
  
  while (k<=i){
    
    
    ind_restants <- nind-k*step
    
    minimum <- min(nind, step, ind_restants)
    
    total <- minimum*nind + res
    
    to_remove1 <- minimum
    to_remove2 <- sum(c((k*step):(k*step+step -1))[1:minimum])
    to_remove = to_remove1 + to_remove2
    
    resp <- res
    res <- total - to_remove
    
    
    
    
    k=k+1
    
  }
  
  
  return(c(resp+1, res))
  
  
}


calcul_index_to_keep <- function(nind, i, step){
  
  
  lignes_to_keep <- calcul1(nind)[calcul2(nind, i, step)[1]:calcul2(nind, i, step)[2]] - i*step*nind
  
  if(is.na(min(lignes_to_keep))){
    lignes_to_keep <- NULL
    
    
  }
  
  return(lignes_to_keep)
}


