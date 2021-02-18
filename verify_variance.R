


# Goal : compute variance of cross, probability to produce a progeny whose GEBV would be lower than a treshold lambda, UC for a specific selection rate q
# Input : marker effects, variance covariance matrix of progeny genotypes, genotyping matrix of parental line, gebv of parental lines, selection intensity table and value of best parental line
# Output : tab which names of parents, and 4 indices : expected GEBV of progeny (u), variance of progeny (sd), probability to be lower than a treshold lambda (log_w) and UC



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



titre_snp_effects <- variables[1]
titre_v_cov_progeny_genotypes <- variables[2]
titre_genotyping_matrix <- variables[3]
titre_gebv <- variables[4]
titre_selection_intensity <- variables[5]
treshold <- as.numeric(variables[6])
selection_rate <- as.numeric(variables[7])
titre_tab1 <- variables[8]
titre_function_calcul <- variables[9]
backingfile1 <- variables[10]


 
[1] "1B"                                                                                  
titre_snp_effects <-  "/work/adanguy/these/croisements/180121/markers_filtered_subset_estimated.txt"        
titre_genotyping_matrix <-  "/work/adanguy/these/croisements/180121/genotyping_matrix_filtered_imputed_subset.txt"
[4] "/work/adanguy/these/croisements/180121/lines.txt"                                    
[5] "/work/adanguy/these/croisements/scripts/calcul_index_variance_crosses.R"             
[6] "1"                                                                                   
[7] "/work/adanguy/these/croisements/180121/variance_crosses_chr/variance_crosses_1B.txt" 
[8] "/work2/genphyse/dynagen/adanguy/croisements/big_files/" 
  
#  


# 
  #  titre_snp_effects <-  "/work/adanguy/these/croisements/031120/snp_effects.txt"                           
  # titre_v_cov_progeny_genotypes <- "/work/adanguy/these/croisements/031120/v_cov_progeny_genotypes2.txt"              
  # titre_genotyping_matrix <-"/work/adanguy/these/croisements/031120/genotyping_matrix.txt"                     
  #  titre_gebv <- "/work/adanguy/these/croisements/031120/gebv.txt"                                  
  #  titre_selection_intensity <- "/work/adanguy/these/croisements/031120/tab3_selection_intensity.txt"              
  #  treshold <- 8.0568953                                                                  
  #  selection_rate <- 0.07                                                                            
  #  titre_tab1 <-"/work/adanguy/these/croisements/031120/tab1_variance_crosses_without_loop.txt"    
  #  titre_function_calcul <- "/work/adanguy/these/croisements/scripts/calcul_index_compute_variance_crosses.R"  
  #  backingfile1 <- "/work2/genphyse/dynagen/adanguy/croisements/big_files/big_files2/big_matrix_1.txt"
  #  backingfile2 <- "/work2/genphyse/dynagen/adanguy/croisements/big_files/big_files2/big_matrix_2.txt"
  #  backingfile3 <- "/work2/genphyse/dynagen/adanguy/croisements/big_files/big_files2/big_matrix_3.txt"
  #  backingfile4 <- "/work2/genphyse/dynagen/adanguy/croisements/big_files/big_files2/big_matrix_4.txt"

cat("\n\n numcores \n\n")
nb_cores()
detectCores()


cat("\n\n INPUT : genotyping matrix updated \n\n")
geno <- fread(titre_genotyping_matrix, header=T)
geno[1:10,1:10]
# column 1 = LINE2 = modified ID for variety (string, 840 levels)
# column 2 - 19751 = genotype at each SNP
# dimension: 840 * 19 751






cat("\n\n INPUT : snp effects from blupf90 \n\n")
snp_effects <- fread(titre_snp_effects)
head(snp_effects)
# column 2 = chr = code number of chr (integers but factors, 21 levels)
# column 3 = pos = physical position of marker (intergers, units bp)
# column 4 = snp_effect = numeric
# column 1-2,5-9 = no importance here
# dim : number of markers * 9



cat("\n\n INPUT : variance covariance matrix of progeny genotype \n\n")
# v_cov <- fread(titre_v_cov_progeny_genotypes)
v_cov <- read.big.matrix(titre_v_cov_progeny_genotypes, header = F, sep="\t", type="double", has.row.names=F)
suppressWarnings(file.remove(paste0(gsub(".txt","",titre_v_cov_progeny_genotypes), ".rds"), paste0(gsub(".txt","",titre_v_cov_progeny_genotypes), ".bk"))) # should write a warning message
v_cov <- read.fbm(titre_v_cov_progeny_genotypes, select=1:(ncol(geno)-1))
v_cov[1:3,1:3]




cat("\n\n INPUT : prediction of GEBV from marker effect \n\n")
gebv <- fread(titre_gebv, header=F)
head(gebv)
# column 1 = LINE2 = modified ID for variety (string, 840 levels)
# column 3 = predicted GEBV from blupf90
# coumn 2 : no importance here
# dimension: 840 * 3

cat("\n\nINPUT : selection intensity table \n\n")
selection_intensity <- fread(titre_selection_intensity)
head(selection_intensity)
#column 1 = x = selection treshold
# column 2 = i = selection intensity
# column 3 = selection rate
# dim 1001*3


### Functions

source(titre_function_calcul)

# calcul3(9, 1, 3)

na.zero <- function (x) {
  x[is.na(x)] <- 0
  return(x)
}





nmark = ncol(v_cov)
nind = nrow(geno)
# nmark=203
nind=3
nmark=50

geno2 <- geno[c(1:nind),]
geno2 <- geno2 %>% dplyr::select(colnames(geno)[c(1:(nmark +1))])


geno2 <- na.zero(geno2)
v_cov <- v_cov[1:nmark, 1:nmark]
v_cov = 0.25*v_cov
# vcov should have 0.25 on diagonal and (1-2*r)/4 out of the diagonal

# geno2[1,2] <- 2
# geno2[1,3] <- 0
# geno2[2,2] <- 0
# geno2[2,3] <- 2
# some formating
effect <- snp_effects %>% arrange(chr, pos) %>% dplyr::select(snp_effect) %>% unlist() %>% as.vector()

# lehermeir formula
i=2
j=3


couple_poly <- geno2[i,-1]- geno2[j,-1]
couple_poly <- which(couple_poly !=0)
parti1 <- sum((effect*effect)[couple_poly])

k=1
l=2
partie2 <- 0
for (k in 1:(nmark -1)){
  
  
  for (l in (k+1):nmark){
    
    
    p1 <- geno2[i,] %>% dplyr::select(colnames(geno2)[c(k,l)+1])*effect[c(k,l)]
    p2 <- geno2[j,] %>% dplyr::select(colnames(geno2)[c(k,l)+1])*effect[c(k,l)]
    
    if (p1[1,1]==p2[1,1] | p1[1,2]==p2[1,2]){
      
      D <- 0
    } else if ((p1[1,1] > p2[1,1] & p1[1,2] > p2[1,2]) | (p2[1,1] > p1[1,1] & p2[1,2] > p1[1,2] )){ # coupling
      
      D <- 1
      
    }else { # repulsion
    
      D <- -1
    }
    
    rec=v_cov[k,l]
    
    
    partie2 <- partie2 + abs(effect[k])*abs(effect[l])*D*rec*4*2 # lehermeir expects that 4*rec = 1-2*r
    
    print(c(k,l,D))
  
}


}

vsd=parti1+partie2
vsd
# geno3 <- geno2
# geno3 <- geno3[,-1]
# geno3[geno3==1] <- 0
# i=2
# j=3
# geno3[geno3==0] <- -1
# geno3[geno3==2] <- 1
# geno3 <- as.matrix(geno3)
# couple_poly <- geno2[i,-1]- geno2[j,-1]
# couple_poly <- which(couple_poly !=0)
# a <- sum(geno3[i,couple_poly]*effect[couple_poly])
# b <- sum(geno3[j,couple_poly]*effect[couple_poly])
# 0.5*a*a + 0.5*b*b

# v_cov <- as.matrix(v_cov)
gebv2 <- gebv %>% rename(line2=V1, gebv=V3)
# extract selection intensity corresponding to selection rate
selection_intensity2=selection_intensity %>% filter(qij==!!selection_rate) %>% dplyr::select(int_qij) %>% unlist() %>% as.vector()
liste_lines <- geno[1:nind,1]



rm(gebv, selection_intensity, snp_effects)












#### calcul des beta : 1 ligne = beta d'un individu
suppressWarnings(file.remove(paste0(backingfile1, ".rds"), paste0(backingfile1, ".bk"))) # should write a warning message
beta <- as_FBM(t(geno2[,-1]),  backingfile = backingfile1) # row = marker, column = individual genotype (0,1,2)
big_apply(beta, ind=rows_along(beta), a.FUN = function(X, ind) {
  X[ind,] <- beta[ind,]*effect[ind]
  NULL  }
  , block.size = 1e2, a.combine="c") # row = marker, column = individual. Cell = genotype (0,1,2)*marker effect
t2 <- Sys.time() 
print(t2-t1)
cat("\nbig_apply 1 done \n")




big_apply(beta, a.FUN = function(beta, ind) {
  beta[, ind] <- na.zero(beta[,ind]) 
  NULL  }
  , block.size = 1e2, a.combine="c") # change NA differences in genotype by 0

t3 <- Sys.time() 
print(t3-t2)
cat("\nbig_apply 2 done \n")



step=5
stop=0
i=0

mu <- as.numeric()
w <- data.frame()

while (stop < nind){ # looping to reduce memory usage. Each loop will care about the step*nind following crosses
  
  start=(step*i) +1
  stop=min(step*(i+1), nind)
  
  mu <- c(mu,unlist(mclapply(1:ncol(beta[,start:stop]), function(x) tcrossprod(crossprod(beta[,start:stop][,x], v_cov[]), t(beta[,start:stop][,x])), mc.cores = nb_cores())))
  
  # mu_temp <- unlist(mclapply(1:ncol(beta[,start:stop]), function(x) tcrossprod(crossprod(beta[,start:stop][,x], v_cov[1:nmark,1:nmark]), t(beta[,start:stop][,x])), mc.cores = nb_cores()))
  # w_temp <- do.call(rbind.data.frame, mclapply(1:ncol(beta[,start:stop]), function(x) crossprod(as.matrix(beta[,start:stop][,x]), v_cov[1:nmark,1:nmark]), mc.cores = nb_cores()))
  w <- rbind(w,do.call(rbind.data.frame, mclapply(1:ncol(beta[,start:stop]), function(x) crossprod(as.matrix(beta[,start:stop][,x]), v_cov[]), mc.cores = nb_cores())))
  
  print(i)
  
  i=i+1
  
  t4 <- Sys.time() 
  print(t4-t3)
  t3 <- t4
  

  
}





t5 <- Sys.time() 
print(t5-t3)
cat("\nw done \n")


i=1
j=2
sd <- as.numeric()
for (i in 1:(nind-1)){
  print(i)
  
  mu_i=mu[i]
  w_i=as.matrix(w[i,])
  
  for (j in (i+1):nind){
    
    
    sd <- c(sd,mu_i+mu[j] -2*tcrossprod(w_i,beta[,j]))
    
    
  }
}

sd
vsd

t6 <- Sys.time() 
print(t6-t5)
rm(mu, w, beta, v_cov)
suppressWarnings(file.remove(paste0(backingfile1, ".rds"), paste0(backingfile1, ".bk"))) # should write a warning message
cat("\nsd done \n")






lines_to_keep <- calcul1(nind)

suppressWarnings(crosses_names <-  expand.grid(unlist(liste_lines[1:nind,1]),
                                               unlist(liste_lines[1:nind,1])) %>%
                   rename(P.x=Var1, P.y=Var2) %>%
                   inner_join(liste_lines[,1] %>%
                                mutate(ordre.x=1:n()), by=c("P.x"="line2"))%>%
                   inner_join(liste_lines[,1] %>%
                                mutate(ordre.y=1:n()), by=c("P.y"="line2")) %>%
                   mutate(P1=ifelse(ordre.x < ordre.y, P.x, P.y)) %>%
                   mutate(P2=ifelse(ordre.y < ordre.x, P.x, P.y)) %>%
                   dplyr::select(P1,P2) %>%
                   slice(lines_to_keep))

t7 <- Sys.time() 
rm(liste_lines)
print(t7-t6)
cat("\n pairwise ID done \n")


# mean of progeny GEBV
u <- matrix(outer(gebv2$gebv[1:nind], gebv2$gebv[1:nind], "+")/2, ncol=1)
u <- u[lines_to_keep]
rm(gebv2, lines_to_keep)
t8 <- Sys.time() 
print(t8-t7)
cat("\n GEBV done \n")





# output
tab <- cbind(crosses_names, sd, u)%>%
  rowwise() %>%
  mutate(log_w=log10(pnorm(treshold, u, sd))) %>%
  mutate(uc=u+selection_intensity2*sd) %>%
  dplyr::select(P1, P2, u, sd, log_w, uc) %>%
  ungroup()
rm(sd, u, crosses_names)
t9 <- Sys.time() 
print(t9-t8)
cat("\n all performance indices done \n")



cat("\n\nOUTPUT : variance of crosses and other performances \n\n")
head(tab)
nrow(tab)
write_delim(tab, titre_tab1, col_names = T, delim="\t", append = F, na="NA", quote_escape="none")
# column 1 = p1 = modified ID of variety (line2) = first parent (string, 840 -1 levels)
# column 2 = p2 = modified ID of variety (line2) = second parent (string, 840 -1 levels)
# column 3 = u = average gebv of parents (from bluf90) (numeric)
# column 4 = sd = sd of progeny gebv (numeric)
# column 5 = log_w = probability to produce a progeny whose gebv is lower than a treshold
# column 6 = uc = expected mean of top q% progeny of a cross





t10 <- Sys.time() 
print(t10-t9)
cat("\n print done \n")



suppressWarnings(file.remove(paste0(gsub(".txt","",titre_v_cov_progeny_genotypes), ".rds"), paste0(gsub(".txt","",titre_v_cov_progeny_genotypes), ".bk"))) # should write a warning message



tf <- Sys.time()
print(tf-t1)
cat("\n total time \n")

sessionInfo()
