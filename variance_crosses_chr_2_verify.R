


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

chr <- "1B"                                                                                  
titre_markers_filtered_subset_estimated <- "/work/adanguy/these/croisements/180121/markers_filtered_subset_estimated.txt"        
titre_genotyping_matrix_filtered_imputated_subset <-  "/work/adanguy/these/croisements/180121/genotyping_matrix_filtered_imputed_subset.txt"
titre_lines <-  "/work/adanguy/these/croisements/180121/lines.txt"                                    
titre_function_calcul_index_variance_crosses <-  "/work/adanguy/these/croisements/scripts/calcul_index_variance_crosses.R"             
nbcores <- 1                                                                                   
titre_variance_crosses_chr <-"/work/adanguy/these/croisements/180121/variance_crosses_chr/variance_crosses_1B.txt" 
r_big_files <- "/work2/genphyse/dynagen/adanguy/croisements/big_files/"  

backingfile1 <- paste0(r_big_files, "big_matrix_1_",chr)
backingfile2 <- paste0(r_big_files, "big_matrix_2_",chr)
backingfile3 <- paste0(r_big_files, "big_matrix_3_",chr)
backingfile4 <- paste0(r_big_files, "big_matrix_4_",chr)
backingfile5 <- paste0(r_big_files, "big_matrix_5_",chr)
backingfile6 <- paste0(r_big_files, "big_matrix_6_",chr)
backingfile7 <- paste0(r_big_files, "big_matrix_7_",chr)
backingfile8 <- paste0(r_big_files, "big_matrix_8_",chr)





cat("\n\n INPUT : genotyping matrix updated \n\n")
geno <- fread(titre_genotyping_matrix_filtered_imputated_subset)
geno[1:10,1:10]
# column 1 = LINE2 = modified ID for variety (string, 840 levels)
# column 2 - 19751 = genotype at each SNP
# dimension: 840 * 19 751






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
# column 1 = LINE2 = modified ID for variety (string, 840 levels)
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
liste_lines <- lines %>% filter(used_as_parent==T) %>%
  dplyr::select(line2) %>%
  arrange(line2) %>%
  unlist() %>%
  as.vector()


#rm(lines)


################### sepcific of chr
colonnes_geno_chr <- markers %>%
  arrange(chr, pos) %>%
  mutate(ligne=1:n()) %>%
  filter(chr==!!chr) %>%
  dplyr::select(marker) %>%
  unlist() %>%
  as.vector()

effect_chr <- markers %>% 
  arrange(chr, pos) %>% 
  filter(chr==!!chr) %>%
  dplyr::select(snp_effect) %>%
  unlist() %>% 
  as.vector()


nmark_chr=length(colonnes_geno_chr)



#### vcov









v_cov <- markers %>% filter(chr ==!!chr)
v_cov <- sapply(1:nrow(v_cov),function(x) abs(v_cov$dcum[x] - v_cov$dcum) )
v_cov <- 0.5*(1-exp(-2*(v_cov/100))) # Haldane mappinf function reciproc
v_cov <- (1-2*v_cov)/4
diag(v_cov) <- 0.25 
suppressWarnings(file.remove(paste0(backingfile1, ".rds"), paste0(backingfile1, ".bk"))) 
v_cov <- as_FBM(v_cov, backingfile = backingfile1) 


# v_cov <- matrix(rep(0.25, times=nmark_chr*nmark_chr), ncol=nmark_chr )
# diag(v_cov) <- 0.25 

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


#rm(matrice)
#suppressWarnings(file.remove(paste0(backingfile2, ".rds"), paste0(backingfile2, ".bk"))) # should write a warning message




### gamma



suppressWarnings(file.remove(paste0(backingfile4, ".rds"), paste0(backingfile4, ".bk"))) # should write a warning message
geno_chr <- as_FBM(geno %>% arrange(line2) %>% dplyr::select(all_of(colonnes_geno_chr)), backingfile = backingfile4) # fast
big_apply(geno_chr, a.FUN = function(geno_chr, ind) {
  geno_chr[, ind] <- na.zero(geno_chr[,ind]) 
  NULL  }
  , block.size = 1e2, a.combine="c") # fast




suppressWarnings(file.remove(paste0(backingfile5, ".rds"), paste0(backingfile5, ".bk"))) # should write a warning message
geno2 <- big_transpose(geno_chr, backingfile = backingfile5) # fast
#rm(geno_chr, colonnes_geno_chr)
#suppressWarnings(file.remove(paste0(backingfile4, ".rds"), paste0(backingfile4, ".bk"))) # should write a warning message




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



#rm(beta, v_cov, v_cov2)
#suppressWarnings(file.remove(paste0(backingfile6, ".rds"), paste0(backingfile6, ".bk"))) # should write a warning message
#suppressWarnings(file.remove(paste0(backingfile3, ".rds"), paste0(backingfile3, ".bk"))) # should write a warning message
#suppressWarnings(file.remove(paste0(backingfile1, ".rds"), paste0(backingfile1, ".bk"))) # should write a warning message






index2 <- lapply(1:ncol(geno2), function(x) as.vector(which(geno2[,x]==2)))
index1 <- lapply(1:ncol(geno2), function(x) as.vector(which(geno2[,x]==1)))
#rm(geno2)
#suppressWarnings(file.remove(paste0(backingfile5, ".rds"), paste0(backingfile5, ".bk"))) # should write a warning message


i=1
j=2
sd <- as.numeric()
for (i in 1:(nind-1)){
  
  print(i)
  
  mu_i=mu[i]
  t_i=t[i,]
  
  
  sd <- c(sd, unlist(mclapply((i+1):nind, function(x)  mu_i+mu[x] - 2*sum( c(2*t_i[index2[[x]]], 1* t_i[index1[[x]]]) ), mc.cores=nbcores)))
  
  
}

# maxi <- length(sd)
#rm(index1, index2, mu, t)
#suppressWarnings(file.remove(paste0(backingfile7, ".rds"), paste0(backingfile7, ".bk"))) # should write a warning message
#suppressWarnings(file.remove(paste0(backingfile8, ".rds"), paste0(backingfile8, ".bk"))) # should write a warning message

lines_to_keep <- calcul1(nind)

suppressWarnings(crosses_names <-  expand.grid(unlist(liste_lines[1:nind]),
                                               unlist(liste_lines[1:nind])) %>%
                   rename(P.x=Var1, P.y=Var2) %>%
                   inner_join(data.frame(line2=liste_lines) %>%
                                
                                mutate(ordre.x=1:n()), by=c("P.x"="line2"))%>%
                   inner_join(data.frame(line2=liste_lines) %>%
                                
                                mutate(ordre.y=1:n()), by=c("P.y"="line2")) %>%
                   mutate(P1=ifelse(ordre.x < ordre.y, as.character(P.x), as.character(P.y))) %>%
                   mutate(P2=ifelse(ordre.y < ordre.x, as.character(P.x), as.character(P.y))) %>%
                   dplyr::select(P1,P2) %>%
                   slice(lines_to_keep))




# output
# tab <- cbind(crosses_names[1:maxi,], sd) %>%
#   mutate(chr=chr)

# tab <- cbind(crosses_names, sd) %>%
#   mutate(chr=chr) %>%
#   mutate(sd =sqrt(sd))

tab <- cbind(crosses_names, sd) %>%
  mutate(chr=chr) 

cat("\n\nOUTPUT : variance of crosses and other performances \n\n")
head(tab)
dim(tab)

tab2 <- data.frame()
size_test=3
liste_lines_test=sort(sample(liste_lines, size=size_test, replace=F))

for (i in 1:(size_test-1)){
  
  index_i = which(liste_lines == liste_lines_test[i])
  print(index_i)
  
  
  for (j in (i+1):size_test ){
    
    
    index_j = which(liste_lines == liste_lines_test[j])
    print(index_j)
    

    Df <- as.numeric()

    couple_poly <- geno_chr[index_i,]- geno_chr[index_j,]
    couple_poly <- which(couple_poly !=0)
    partie1 <- sum((effect_chr*effect_chr)[couple_poly])
    
    
    

    
    partie2 <- 0
    for (k in 1:(nmark_chr -1)){
      
      
      for (l in (k+1):nmark_chr){
        
        
        p1 <- geno_chr[index_i,][c(k,l)]*effect_chr[c(k,l)]
        p2 <- geno_chr[index_j,][c(k,l)]*effect_chr[c(k,l)]
        
        if (p1[1]==p2[1] | p1[2]==p2[2]){
          
          D <- 0
        } else if ((p1[1] >= p2[1] & p1[2] >= p2[2] & p1[1]!= p2[1] ) | (p2[1] >= p1[1] & p2[2] >= p1[2] & p1[1]!= p2[1])){ # coupling
          
          D <- 1
          
        }else { # repulsion
          
          D <- -1
        }
        
        
        Df <- c(Df, D)
        
        rec=v_cov[k,l]
        
        
        partie2 <- partie2 + abs(effect_chr[k])*abs(effect_chr[l])*D*rec*4*2 # lehermeir expects that 4*rec = 1-2*r
        # partie2 <- partie2 + abs(effect_chr[k])*abs(effect_chr[l])*D*rec*4*2 # lehermeir expects that 4*rec = 1-2*r
        
        # print(c(k,l,D))
        
      }
      
      
    }
    
    v_lehermeier = partie1 + partie2
    
    tab2 <- rbind(tab2, data.frame(P1=liste_lines_test[i], P2=liste_lines_test[j], v_lehermeier=v_lehermeier))
    
  }
}


comparaison <- tab2 %>% inner_join(tab, by=c("P1"="P1", "P2"="P2"))
comparaison




tf <- Sys.time()
print(tf-t1)
cat("\ntotal time \n")

sessionInfo()
