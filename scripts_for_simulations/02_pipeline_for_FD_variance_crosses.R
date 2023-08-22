


Sys.time()
cat("\n\n02_pipeline_for_FD_variance_of_crosses.R\n\n")
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


divariables <- commandArgs(trailingOnly=TRUE)
cat("\n\nVariables : \n")
print(variables)
cat("\n\n")


titre_markers_input <- variables[1]
titre_genotyping_input <- variables[2]
titre_crosses_input <- variables[3]
r_big_files <- variables[4]
progeny <- variables[5]
k <- as.numeric(variables[6])
sel_intensity <- as.numeric(variables[7])
best_parental_line <- as.numeric(variables[8])
titre_crosses_output <- variables[9]


chr <- "1A"
titre_markers_input <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/FD_markers.txt"
titre_genotyping_input <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/FD_genotyping.txt"
r_big_files <-  "/home/adanguydesd/Documents/These_Alice/croisements/temp/"
titre_crosses_output <-  "/home/adanguydesd/Documents/These_Alice/croisements/temp/FD_variance_of_crosses_for_chr1A.txt"
titre_crosses_input <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/FD_crosses.txt"
progeny <- "HDs"
k <- 1 # for F5, take k=4 ; for F6, take k=5...
sel_intensity <- 2
best_parental_line <- 3
titre_crosses_output <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/FD_crosses2.txt"



backingfile1 <- paste0(r_big_files, "big_matrix_1_",chr)
backingfile2 <- paste0(r_big_files, "big_matrix_2_",chr)
backingfile3 <- paste0(r_big_files, "big_matrix_3_",chr)
backingfile4 <- paste0(r_big_files, "big_matrix_4_",chr)
backingfile5 <- paste0(r_big_files, "big_matrix_5_",chr)
backingfile6 <- paste0(r_big_files, "big_matrix_6_",chr)
backingfile7 <- paste0(r_big_files, "big_matrix_7_",chr)
backingfile8 <- paste0(r_big_files, "big_matrix_8_",chr)





cat("\n\n INPUT : genotyping data \n\n")
g <- fread(titre_genotyping_input) 
g %>% select(1:10) %>% slice(1:10)
g%>% select(1:10) %>% slice((nrow(.)-10):nrow(.))
g%>% dim()






cat("\n\n INPUT : markers data \n\n")
m <- fread(titre_markers_input)
m%>% head()
m %>% tail()
m %>% dim()


cat("\n\n INPUT : crosses data \n\n")
c <- fread(titre_crosses_input)
c %>% head()
c %>% tail()
c %>% dim()

### Functions

calcul_index_to_keep <- function(nind){
  
  to_supress <- as.numeric()
  
  same_line <- seq(0,nind*nind, nind)+1
  
  for (k in 1:nind){
    
    to_supress <- c(to_supress, seq(same_line[k], same_line[k]+(k-1), 1))
    
    
  }
  
  lignes <- c(1:(nind*nind))
  lignes <- lignes[-to_supress]
  
  
  return(lignes)
  
  
}

###

np = nrow(g)


calcul_variance <- function(m, g, chr, progeny, k) {



################### marker of the chr
colonnes_g_chr <- m %>%
  filter(chr==!!chr) %>%
  dplyr::select(marker) %>%
  unlist() %>%
  as.vector() # column to keep in genotyping matrix




nm=length(colonnes_g_chr) # number of markers



#### STEP 1 : compute variance-covariance matrix of progenies genotypes

  
mchr <- m%>%
  filter(chr==!!chr)  

effect_chr <- mchr %>%
  dplyr::select(one_of("value")) %>%
  unlist() %>%
  as.vector()

  
if (nrow(mchr) >=2){
  
  
  
  c1 <- sapply(1:nrow(mchr),function(x) abs(mchr[x, "dcum"] - mchr[,"dcum"]) ) # for now, c1 is cM/Mb
  c1 <- 0.5*(1-exp(-2*(c1/100))) # reciproque of Haldane mapping function gives expected recombination fraction (%). The factor 100 is to convert cM to M
  ck = (2*c1/(1+2*c1))*(1-(((0.5)^k)*((1-2*c1)^k))) # expected recombination fraction after k generation of selfing, from Lehermeier & al. 2017
  
  if (progeny=="HDs"){
    
    v_cov = (1-(2*ck))/4 # variance-covariance matrix of pairwise locus after k generation of selfing and then doubling
    
  } else if (progeny=="RILs"){
  
  v_cov = (1 - 2*ck - ((0.5*(1-2*c1))^k))/4 # variance-covariance matrix of pairwise locus after k generation of selfing 
  diag(v_cov) <- 1/4  # variance at one locus
  
  }
  # difference from Lehermeier is the factor 1/4 (both in variance and covariance), because we use a sliglty different method in next steps
  
  suppressWarnings(file.remove(paste0(backingfile1, ".rds"), paste0(backingfile1, ".bk"))) 
  v_cov <- as_FBM(v_cov, backingfile = backingfile1) 
  

  
  
  ### STEP 2 : Include effect of markers
  
  
  
  matrice <- matrix(rep(0, times=nm*nm), ncol=nm)
  diag(matrice) <- effect_chr #B
  suppressWarnings(file.remove(paste0(backingfile2, ".rds"), paste0(backingfile2, ".bk"))) # should write a warning message
  matrice <- as_FBM(matrice, backingfile = backingfile2)
  
  suppressWarnings(file.remove(paste0(backingfile3, ".rds"), paste0(backingfile3, ".bk"))) # should write a warning message
  v_cov2 <- FBM(nm, nm, backingfile=backingfile3)
  big_apply(v_cov2, a.FUN = function(X, ind) {
    X[,ind] <- crossprod(matrice, v_cov[,ind])
    NULL  }
    , block.size = block_size(1e2,ncores=1), a.combine="c") # B*D
  
  
  big_apply(v_cov2, a.FUN = function(X, ind) {
    X[,ind] <-tcrossprod(v_cov2, matrice[ind,])
    NULL  }
    , block.size = block_size(1e2,ncores=1), a.combine="c") # B*D
  
  
  rm(matrice)
  suppressWarnings(file.remove(paste0(backingfile2, ".rds"), paste0(backingfile2, ".bk"))) # should write a warning message
  
  
  
  
  ### STEP3 : beta = genotype (0,1,2) * marker effect
  
  
  
  suppressWarnings(file.remove(paste0(backingfile4, ".rds"), paste0(backingfile4, ".bk"))) 
  g_chr <- as_FBM(g %>% dplyr::select(all_of(colonnes_g_chr)), backingfile = backingfile4) 
  suppressWarnings(file.remove(paste0(backingfile5, ".rds"), paste0(backingfile5, ".bk"))) 
  g_chr2 <- big_transpose(g_chr, backingfile = backingfile5) # fast
  suppressWarnings(file.remove(paste0(backingfile4, ".rds"), paste0(backingfile4, ".bk"))) 
  suppressWarnings(file.remove(paste0(backingfile6, ".rds"), paste0(backingfile6, ".bk"))) 
  beta <- big_copy(g_chr2,  backingfile = backingfile6) 
  big_apply(beta, ind=rows_along(beta), a.FUN = function(X, ind) {
    X[ind,] <- beta[ind,]*effect_chr[ind]
    NULL  }
    , block.size = block_size(1e2, ncores=1), a.combine="c") 
  
  # STEP4 : mu = beta* vcov
  
  
  
  suppressWarnings(file.remove(paste0(backingfile7, ".rds"), paste0(backingfile7, ".bk")))
  mu <- FBM(nrow=1, ncol=np,  backingfile = backingfile7)
  big_apply(mu, a.FUN = function(X, ind) {
    X[,ind] <- diag(tcrossprod(crossprod(as.matrix(beta[,ind]), v_cov), t(beta[,ind])))
    NULL  }
    , block.size = block_size(1e2,ncores=1), a.combine="c") 
  
  
  
  # STEP 5 : t = genot * vcov2
  
  suppressWarnings(file.remove(paste0(backingfile8, ".rds"), paste0(backingfile8, ".bk"))) 
  t <- FBM(nrow=np, ncol=nm,  backingfile = backingfile8)
  big_apply(t, ind=rows_along(t), a.FUN = function(X, ind) {
    X[ind,] <- crossprod(g_chr2[,ind], v_cov2)
    NULL  }
    , block.size = block_size(1e2,ncores=1), a.combine="c") 
  
  
  
  rm(beta, v_cov, v_cov2)
  suppressWarnings(file.remove(paste0(backingfile6, ".rds"), paste0(backingfile6, ".bk"))) # should write a warning message
  suppressWarnings(file.remove(paste0(backingfile3, ".rds"), paste0(backingfile3, ".bk"))) # should write a warning message
  suppressWarnings(file.remove(paste0(backingfile1, ".rds"), paste0(backingfile1, ".bk"))) # should write a warning message
  
  
  
  
  
  
  index2 <- lapply(1:ncol(g_chr2), function(x) as.vector(which(g_chr2[,x]==2)))
  index1 <- lapply(1:ncol(g_chr2), function(x) as.vector(which(g_chr2[,x]==1)))
  rm(g_chr2)
  suppressWarnings(file.remove(paste0(backingfile5, ".rds"), paste0(backingfile5, ".bk"))) # should write a warning message
  
  
  i=1
  j=2
  variance <- as.numeric()
  for (i in 1:(np-1)){
    

    mu_i=mu[i]
    t_i=t[i,]
    
    
    variance <- c(variance, unlist(mclapply((i+1):np, function(x)  mu_i+mu[x] - 2*sum( c(2*t_i[index2[[x]]], 1* t_i[index1[[x]]]) ), mc.cores=1)))
    
    
  }
  
  # maxi <- length(variance)
  rm(index1, index2, mu, t)
  suppressWarnings(file.remove(paste0(backingfile7, ".rds"), paste0(backingfile7, ".bk"))) # should write a warning message
  suppressWarnings(file.remove(paste0(backingfile8, ".rds"), paste0(backingfile8, ".bk"))) # should write a warning message
  

  
  } else if (nrow(mchr)==1) {
    
    
    
    
    lines_to_keep <- calcul_index_to_keep(np)
    
    
    g2 <- g %>% dplyr::select(ID, one_of(colonnes_g_chr)) %>% as.data.frame()

    variance <- matrix(outer(as.matrix(g2[,colonnes_g_chr]), as.matrix(g2[,colonnes_g_chr]), "-"), ncol=1)[lines_to_keep,]
    
    variance <- abs(variance)
    
    variance[which(variance==2)] <- effect_chr*effect_chr
    variance[which(variance==1)] <- effect_chr*effect_chr*0.75

    
    
    
    
    
    
    
    
    
  }
  
  return(variance)
  
  
  
}

variance <- 0
for (chr in unique(m$chr)){

variance <- variance + calcul_variance(m=m, g=g, chr=chr, progeny=progeny, k=k)

}





lines_to_keep <- calcul_index_to_keep(np)

suppressWarnings(crosses_names <-  expand.grid(unlist(g$ID),
                                               unlist(g$ID)) %>%
                   rename(P.x=Var1, P.y=Var2) %>%
                   inner_join(data.frame(ID=g$ID) %>%
                                
                                mutate(ordre.x=1:n()), by=c("P.x"="ID"))%>%
                   inner_join(data.frame(ID=g$ID) %>%
                                
                                mutate(ordre.y=1:n()), by=c("P.y"="ID")) %>%
                   mutate(P1=ifelse(ordre.x < ordre.y, as.character(P.x), as.character(P.y))) %>%
                   mutate(P2=ifelse(ordre.y < ordre.x, as.character(P.x), as.character(P.y))) %>%
                   dplyr::select(P1,P2) %>%
                   slice(lines_to_keep))


tab <- data.frame(P1=crosses_names$P1, 
                  P2=crosses_names$P2, 
                  variance=variance) %>%
  arrange(P1, P2)%>%
  mutate(variance=ifelse(variance < 0, 0, variance)) %>% # sometimes variance is -xx*1e-17, so bring back to 0
    mutate(sd=sqrt(variance)) %>%
  mutate(P1=as.character(P1)) %>%
  mutate(P2=as.character(P2)) %>%
  right_join(c, by=c("P1"="P1", "P2"="P2")) %>%
  mutate(uc=gebv + sel_intensity*sd) %>%
  mutate(uc_extreme=gebv + 3.958483*sd) %>%
  mutate(logw = log10(pnorm(best_parental_line, m=gebv, sd=sd))) %>%
  arrange(P1, P2)%>%
  dplyr::select(P1, P2, gebv, sd, logw, uc, uc_extreme)
  
    


cat("\n\nOUTPUT : crosses \n\n")
head(tab)
tail(tab)
dim(tab)
write_delim(tab, titre_crosses_output, col_names = T, delim="\t", append = F, na="NA", quote_escape="none")



sessionInfo()
