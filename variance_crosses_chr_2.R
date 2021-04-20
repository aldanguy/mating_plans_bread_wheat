


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
titre_markers_filtered_subset_estimated <- variables[2]
titre_genotyping_matrix_filtered_imputated_subset <- variables[3]
titre_lines <- variables[4]
titre_function_calcul_index_variance_crosses <- variables[5]
nbcores <- as.numeric(variables[6])
titre_variance_crosses_chr <- variables[7]
r_big_files <- variables[8]
population <- variables[9]
type <- variables[10]

ID=paste0(type,"_",chr,"_",population)

  

 # chr <- "1A"                                                                                                            
 # titre_markers_filtered_subset_estimated <-  "/work2/genphyse/dynagen/adanguy/croisements/150221/value_crosses/markers_filtered_estimated.txt"        
 # titre_genotyping_matrix_filtered_imputated_subset <- "/work2/genphyse/dynagen/adanguy/croisements/150221/prepare/genotyping_matrix_filtered_imputed.txt"
 # titre_lines <-"/work2/genphyse/dynagen/adanguy/croisements/150221/prepare/lines.txt"                                          
 # titre_function_calcul_index_variance_crosses <- "/work/adanguy/these/croisements/scripts/calcul_index_variance_crosses.R"                                       
 # nbcores <- 1                                                                                                         
 # titre_variance_crosses_chr <- "/work2/genphyse/dynagen/adanguy/croisements/150221/value_crosses/variance_crosses_chr/variance_crosses_1A.txt" 
 # r_big_files <-  "/work2/genphyse/dynagen/adanguy/croisements/150221/value_crosses/variance_crosses_chr/big_matrix/"  
 # population <- "WE"
 # type="marker_simFALSE_10cm"


backingfile1 <- paste0(r_big_files, "big_matrix_1_",ID)
backingfile2 <- paste0(r_big_files, "big_matrix_2_",ID)
backingfile3 <- paste0(r_big_files, "big_matrix_3_",ID)
backingfile4 <- paste0(r_big_files, "big_matrix_4_",ID)
backingfile5 <- paste0(r_big_files, "big_matrix_5_",ID)
backingfile6 <- paste0(r_big_files, "big_matrix_6_",ID)
backingfile7 <- paste0(r_big_files, "big_matrix_7_",ID)
backingfile8 <- paste0(r_big_files, "big_matrix_8_",ID)





cat("\n\n INPUT : genotyping matrix updated \n\n")
geno <- fread(titre_genotyping_matrix_filtered_imputated_subset)
geno[1:10,1:10]
# column 1 = ID = modified ID for variety (string, 840 levels)
# column 2 - 19751 = genotype at each SNP
# dimension: 840 * 19 751
dim(geno)





cat("\n\n INPUT : snp effects from blupf90 \n\n")
markers <- fread(titre_markers_filtered_subset_estimated)
head(markers)
# column 2 = chr = code number of chr (integers but factors, 21 levels)
# column 3 = pos = physical position of marker (intergers, units bp)
# column 4 = snp_effect = numeric
# column 1-2,5-9 = no importance here
# dim : number of markers * 9


cat("\n\n INPUT : prediction of GEBV from marker effect \n\n")
lines <- fread(titre_lines)
head(lines)
# column 1 = ID = modified ID for variety (string, 840 levels)
# column 3 = predicted GEBV from blupf90
# coumn 2 : no importance here
# dimension: 840 * 3


### Functions

source(titre_function_calcul_index_variance_crosses)

# calcul3(9, 1, 3)

na.zero <- function (x) {
  x[is.na(x)] <- 0
  return(x)
}


### first steps


nind = nrow(geno)


# lines ID
liste_lines <- lines %>% filter(used_as_parent==T & generation==0 & type=="pheno_simFALSE") %>%
  arrange(ID) %>%
  dplyr::select(ID) %>%
  unlist() %>%
  as.vector()


rm(lines)


################### sepcific of chr
colonnes_geno_chr <- markers %>%
  arrange(chr, pos, marker, population) %>%
  filter(population==!!population) %>%
  filter(type==!!type) %>%
  filter(chr==!!chr) %>%
  filter(value !=0) %>%
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
  sd <- as.numeric()
  for (i in 1:(nind-1)){
    

    mu_i=mu[i]
    t_i=t[i,]
    
    
    sd <- c(sd, unlist(mclapply((i+1):nind, function(x)  mu_i+mu[x] - 2*sum( c(2*t_i[index2[[x]]], 1* t_i[index1[[x]]]) ), mc.cores=nbcores)))
    
    
  }
  
  # maxi <- length(sd)
  rm(index1, index2, mu, t)
  suppressWarnings(file.remove(paste0(backingfile7, ".rds"), paste0(backingfile7, ".bk"))) # should write a warning message
  suppressWarnings(file.remove(paste0(backingfile8, ".rds"), paste0(backingfile8, ".bk"))) # should write a warning message
  
 
  
  return(sd)
  
  
  
}
sd <- calcul_variance_crosses_chr(population=population, type=type, chr=chr)


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
tab <- data.frame(P1=crosses_names$P1, P2=crosses_names$P2, chr=chr, type=type, sd=sd) %>%
  arrange(P1, P2)



    
    


# tab <- cbind(crosses_names, sd) %>%
#   mutate(chr=chr) 

cat("\n\nOUTPUT : variance of crosses and other performances \n\n")
head(tab)
tail(tab)
dim(tab)
write_delim(tab, titre_variance_crosses_chr, col_names = T, delim="\t", append = F, na="NA", quote_escape="none")
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
