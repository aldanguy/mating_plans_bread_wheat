


# Goal : compute variance of cross, probability to produce a progeny whose GEBV would be lower than a treshold lambda, UC for a specific selection rate q
# Input : marker effects, variance covariance matrix of progeny genotypes, genotyping matrix of parental line, gebv of parental lines, selection intensity table and value of best parental line
# Output : tab which names of parents, and 4 indices : expected GEBV of progeny (u), variance of progeny (sd), probability to be lower than a treshold lambda (log_w) and UC



# warning : GEBV and geno has to have the same order for LINES
# warning : effects and geno has to have the same order for SNP


Sys.time()
cat("\n\ncompute_variance_cross.R\n\n")
rm(list = ls())
graphics.off()
set.seed(1)
t1 <-Sys.time() 

suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(compiler))
suppressPackageStartupMessages(library(bigstatsr))
suppressPackageStartupMessages(library(bigmemory))
suppressPackageStartupMessages(library(readr))
suppressPackageStartupMessages(library(parallel))
suppressPackageStartupMessages(library(Directional))


variables <- commandArgs(trailingOnly=TRUE)
cat("\n\nVariables : \n")
print(variables)
cat("\n\n")


chr <- variables[1]
titre_markers_input <- variables[2]
titre_genotyping_input <- variables[3]
titre_lines_input <- variables[4]
titre_function_calcul_index_variance_crosses <- variables[5]
nbcores <- as.numeric(variables[6])
titre_variance_crosses_chr_output <- variables[7]
r_big_files <- variables[8]
population <- variables[9]
type <- variables[10]
generation <- as.numeric(variables[11])

# chr <- "1A"                                                                                                                         
# titre_markers_input <- "/work2/genphyse/dynagen/adanguy/croisements/050321/value_crosses/markers_estimated_marker_simTRUE_chrcm_r2_WE.txt"          
# titre_genotyping_input <-  "/work2/genphyse/dynagen/adanguy/croisements/050321/prepare/genotyping.txt"                                                  
# titre_lines_input <-  "/work2/genphyse/dynagen/adanguy/croisements/050321/value_crosses/lines_estimated_simTRUE_chrcm_r2.txt"                      
# titre_function_calcul_index_variance_crosses <- "/work/adanguy/these/croisements/scripts/calcul_index_variance_crosses.R"                                                    
# nbcores <- "2"                                                                                                                          
# titre_variance_crosses_chr_output <-"/work2/genphyse/dynagen/adanguy/croisements/050321/value_crosses/crosses/variance_crosses_chr_g1_simTRUE_chrcm_r2_WE_1A.txt"
# r_big_files <-  "/work2/genphyse/dynagen/adanguy/croisements/050321/value_crosses/crosses/"                                                  
# population <-  "WE"                                                                                                                         
# type <-  "marker_simTRUE_chrcm_r2"                                                                                                    
# generation <- 1

motif=gsub("marker_", "", type)

motif2=paste0("g",generation,"_", motif,"_",population,"_",chr)


backingfile1 <- paste0(r_big_files, "big_matrix_1_",motif2)
backingfile2 <- paste0(r_big_files, "big_matrix_2_",motif2)
backingfile3 <- paste0(r_big_files, "big_matrix_3_",motif2)
backingfile4 <- paste0(r_big_files, "big_matrix_4_",motif2)
backingfile5 <- paste0(r_big_files, "big_matrix_5_",motif2)
backingfile6 <- paste0(r_big_files, "big_matrix_6_",motif2)
backingfile7 <- paste0(r_big_files, "big_matrix_7_",motif2)
backingfile8 <- paste0(r_big_files, "big_matrix_8_",motif2)





cat("\n\n INPUT : genotyping \n\n")
geno <- fread(titre_genotyping_input) 
geno %>% select(1:10) %>% slice(1:10)
geno%>% select(1:10) %>% slice((nrow(.)-10):nrow(.))
geno%>% dim()
geno <- geno %>%
  dplyr::select(ID, starts_with("AX"))






cat("\n\n INPUT : markers info \n\n")
markers <- fread(titre_markers_input)
markers%>% head()
markers %>% tail()
markers %>% dim()


cat("\n\n INPUT : lines info \n\n")
lines <- fread(titre_lines_input)
lines %>% head()
lines %>% tail()
lines %>% dim()

### Functions

source(titre_function_calcul_index_variance_crosses)

# calcul3(9, 1, 3)

na.zero <- function (x) {
  x[is.na(x)] <- 0
  return(x)
}


### first steps


nind = nrow(geno)


if (grepl("_h", type) | grepl("simFALSE", type)){
  
  
  motif_line <- "gebv"
  
} else {
  
  motif_line <- "tbv"
  
}


# lines ID
liste_lines <- lines %>% filter(used_as_parent==T  & endsWith(type, motif)==T & grepl(motif_line, type)) %>%
  arrange(ID) %>%
  dplyr::select(ID) %>%
  unlist() %>%
  as.vector()

cat("\n\nlist lines\n\n")
length(liste_lines)

rm(lines)


################### sepcific of chr
colonnes_geno_chr <- markers %>%
  arrange(chr, pos, marker, population) %>%
  filter(population==!!population) %>%
  filter(chr==!!chr) %>%
  filter(value !=0) %>%
  rowwise() %>%
  filter(endsWith(type, motif)==T) %>%
  dplyr::select(marker) %>%
  unlist() %>%
  as.vector()




nmark_chr=length(colonnes_geno_chr)



#### vcov

calcul_variance_crosses_chr <- function(population, type, chr){
  

  
  
  v_cov <- markers %>%
    arrange(chr, pos, marker, population) %>%
    filter(population==!!population) %>%
    filter(type==!!type) %>%
    filter(chr==!!chr)  %>%
    filter(value !=0)

  
  if (nrow(v_cov) >=2){
  
  v_cov <- sapply(1:nrow(v_cov),function(x) abs(v_cov[x, "dcum"] - v_cov[,"dcum"]) )
  v_cov <- 0.5*(1-exp(-2*(v_cov/100))) # Haldane mappinf function reciproc
  v_cov <- (1-2*v_cov)/4
  diag(v_cov) <- 0.25 
  
  

  
  suppressWarnings(file.remove(paste0(backingfile1, ".rds"), paste0(backingfile1, ".bk"))) 
  v_cov <- as_FBM(v_cov, backingfile = backingfile1) 
  
  effect_chr <- markers %>%
    arrange(chr, pos, marker, population) %>%
    filter(population==!!population) %>%
    filter(type==!!type) %>%
    filter(chr==!!chr) %>% 
    filter(value !=0) %>%
    dplyr::select(one_of("value")) %>%
    unlist() %>%
    as.vector()
  
  
  ### vcov2
  
  
  
  matrice <- matrix(rep(0, times=nmark_chr*nmark_chr), ncol=nmark_chr)
  diag(matrice) <- effect_chr #B
  suppressWarnings(file.remove(paste0(backingfile2, ".rds"), paste0(backingfile2, ".bk"))) # should write a warning message
  matrice <- as_FBM(matrice, backingfile = backingfile2)
  
  suppressWarnings(file.remove(paste0(backingfile3, ".rds"), paste0(backingfile3, ".bk"))) # should write a warning message
  v_cov2 <- FBM(nmark_chr, nmark_chr, backingfile=backingfile3)
  big_apply(v_cov2, a.FUN = function(X, ind) {
    X[,ind] <- crossprod(matrice, v_cov[,ind])
    NULL  }
    , block.size = block_size(1e2,ncores=nbcores), a.combine="c") # B*D
  
  
  big_apply(v_cov2, a.FUN = function(X, ind) {
    X[,ind] <-tcrossprod(v_cov2, matrice[ind,])
    NULL  }
    , block.size = block_size(1e2,ncores=nbcores), a.combine="c") # B*D
  
  
  rm(matrice)
  suppressWarnings(file.remove(paste0(backingfile2, ".rds"), paste0(backingfile2, ".bk"))) # should write a warning message
  
  
  
  
  ### gamma
  
  
  
  suppressWarnings(file.remove(paste0(backingfile4, ".rds"), paste0(backingfile4, ".bk"))) # should write a warning message
  geno_chr <- as_FBM(geno %>% arrange(ID) %>% dplyr::select(all_of(colonnes_geno_chr)), backingfile = backingfile4) # fast
  big_apply(geno_chr, a.FUN = function(geno_chr, ind) {
    geno_chr[, ind] <- na.zero(geno_chr[,ind]) 
    NULL  }
    , block.size = 1e2, a.combine="c") # fast
  
  
  
  
  suppressWarnings(file.remove(paste0(backingfile5, ".rds"), paste0(backingfile5, ".bk"))) # should write a warning message
  geno2 <- big_transpose(geno_chr, backingfile = backingfile5) # fast
  #rm(geno_chr, colonnes_geno_chr)
  suppressWarnings(file.remove(paste0(backingfile4, ".rds"), paste0(backingfile4, ".bk"))) # should write a warning message
  
  
  
  
  #### calcul des beta : 1 ligne = beta d'un individu
  suppressWarnings(file.remove(paste0(backingfile6, ".rds"), paste0(backingfile6, ".bk"))) # should write a warning message
  beta <- big_copy(geno2,  backingfile = backingfile6) # row = marker, column = individual genotype (0,1,2)
  big_apply(beta, ind=rows_along(beta), a.FUN = function(X, ind) {
    X[ind,] <- beta[ind,]*effect_chr[ind]
    NULL  }
    , block.size = block_size(1e2, ncores=nbcores), a.combine="c") # row = marker, column = individual. Cell = genotype (0,1,2)*marker effect
  # fast
  #rm(effect_chr)
  
  
  
  
  
  suppressWarnings(file.remove(paste0(backingfile7, ".rds"), paste0(backingfile7, ".bk"))) # should write a warning message
  mu <- FBM(nrow=1, ncol=nind,  backingfile = backingfile7) # row = marker, column = individual genotype (0,1,2)
  big_apply(mu, a.FUN = function(X, ind) {
    X[,ind] <- diag(tcrossprod(crossprod(as.matrix(beta[,ind]), v_cov), t(beta[,ind])))
    NULL  }
    , block.size = block_size(1e2,ncores=nbcores), a.combine="c") 
  
  
  
  
  
  suppressWarnings(file.remove(paste0(backingfile8, ".rds"), paste0(backingfile8, ".bk"))) # should write a warning message
  t <- FBM(nrow=nind, ncol=nmark_chr,  backingfile = backingfile8) # row = marker, column = individual genotype (0,1,2)
  big_apply(t, ind=rows_along(t), a.FUN = function(X, ind) {
    X[ind,] <- crossprod(geno2[,ind], v_cov2)
    NULL  }
    , block.size = block_size(1e2,ncores=nbcores), a.combine="c") 
  
  
  
  rm(beta, v_cov, v_cov2)
  suppressWarnings(file.remove(paste0(backingfile6, ".rds"), paste0(backingfile6, ".bk"))) # should write a warning message
  suppressWarnings(file.remove(paste0(backingfile3, ".rds"), paste0(backingfile3, ".bk"))) # should write a warning message
  suppressWarnings(file.remove(paste0(backingfile1, ".rds"), paste0(backingfile1, ".bk"))) # should write a warning message
  
  
  
  
  
  
  index2 <- lapply(1:ncol(geno2), function(x) as.vector(which(geno2[,x]==2)))
  index1 <- lapply(1:ncol(geno2), function(x) as.vector(which(geno2[,x]==1)))
  rm(geno2)
  suppressWarnings(file.remove(paste0(backingfile5, ".rds"), paste0(backingfile5, ".bk"))) # should write a warning message
  
  
  i=1
  j=2
  variance <- as.numeric()
  for (i in 1:(nind-1)){
    

    mu_i=mu[i]
    t_i=t[i,]
    
    
    variance <- c(variance, unlist(mclapply((i+1):nind, function(x)  mu_i+mu[x] - 2*sum( c(2*t_i[index2[[x]]], 1* t_i[index1[[x]]]) ), mc.cores=nbcores)))
    
    
  }
  
  # maxi <- length(variance)
  rm(index1, index2, mu, t)
  suppressWarnings(file.remove(paste0(backingfile7, ".rds"), paste0(backingfile7, ".bk"))) # should write a warning message
  suppressWarnings(file.remove(paste0(backingfile8, ".rds"), paste0(backingfile8, ".bk"))) # should write a warning message
  
 
  
  } else if (nrow(v_cov)==1) {
    
    
    m <- markers %>%
      arrange(chr, pos, marker, population) %>%
      filter(population==!!population) %>%
      filter(type==!!type) %>%
      filter(chr==!!chr) %>% 
      filter(value !=0) %>%
      dplyr::select(marker) %>% unlist() %>%
      as.vector()
    
    effect_chr <- markers %>%
      arrange(chr, pos, marker, population) %>%
      filter(population==!!population) %>%
      filter(type==!!type) %>%
      filter(chr==!!chr) %>% 
      filter(value !=0) %>%
      dplyr::select(one_of("value")) %>%
      unlist() %>%
      as.vector()
    
    lines_to_keep <- calcul1(nind)
    
    
    geno2 <- geno %>% dplyr::select(ID, one_of(m)) %>% as.data.frame()

    variance <- matrix(outer(geno2[,m], geno2[,m], "-"), ncol=1)[lines_to_keep,]
    
    variance <- abs(variance)
    
    variance[which(variance==2)] <- effect_chr*effect_chr
    variance[which(variance==1)] <- effect_chr*effect_chr*0.75
    variance[which(variance==0)] <- 0
    
    
    
    
    
    
    
    
    
    
  }
  
  return(variance)
  
  
  
}




variance <- calcul_variance_crosses_chr(population=population, type=type, chr=chr)



lines_to_keep <- calcul1(nind)

suppressWarnings(crosses_names <-  expand.grid(unlist(liste_lines[1:nind]),
                                               unlist(liste_lines[1:nind])) %>%
                   rename(P.x=Var1, P.y=Var2) %>%
                   inner_join(data.frame(ID=liste_lines) %>%
                                
                                mutate(ordre.x=1:n()), by=c("P.x"="ID"))%>%
                   inner_join(data.frame(ID=liste_lines) %>%
                                
                                mutate(ordre.y=1:n()), by=c("P.y"="ID")) %>%
                   mutate(P1=ifelse(ordre.x < ordre.y, as.character(P.x), as.character(P.y))) %>%
                   mutate(P2=ifelse(ordre.y < ordre.x, as.character(P.x), as.character(P.y))) %>%
                   dplyr::select(P1,P2) %>%
                   slice(lines_to_keep))
tab <- data.frame(P1=crosses_names$P1, P2=crosses_names$P2, generation=generation, type=type, population=population, chr=chr, 
                  variance=variance) %>%
  arrange(P1, P2)


tab <- tab %>% mutate(variance=ifelse(variance < 0, 0, variance)) # sometimes variance is xx*1e-17, so bring back to 0
    
    


# tab <- cbind(crosses_names, sd) %>%
#   mutate(chr=chr) 

cat("\n\nOUTPUT : variance of crosses \n\n")
head(tab)
tail(tab)
dim(tab)
write_delim(tab, titre_variance_crosses_chr_output, col_names = T, delim="\t", append = F, na="NA", quote_escape="none")
# column 1 = p1 = modified ID of variety (ID) = first parent (string, 840 -1 levels)
# column 2 = p2 = modified ID of variety (ID) = second parent (string, 840 -1 levels)
# column 3 = u = average gebv of parents (from bluf90) (numeric)
# column 4 = sd = sd of progeny gebv (numeric)
# column 5 = log_w = probability to produce a progeny whose gebv is lower than a treshold
# column 6 = uc = expected mean of top q% progeny of a cross





tf <- Sys.time()
print(tf-t1)
cat("\ntotal time \n")

sessionInfo()
