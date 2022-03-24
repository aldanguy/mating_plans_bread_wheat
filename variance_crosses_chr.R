


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


titre_markers_input <- variables[1]
titre_genotypes_parents_input <- variables[2]
nbcores <- as.numeric(variables[3])
chr <- variables[4]
progeny <- variables[5]
titre_function_calcul_index_variance_crosses <- variables[6]
r_big_files <- variables[7]
titre_variance_crosses_chr_output <- variables[8]
titre_lines_input <- variables[9]
titre_genetic_map_input <- variables[10]


# titre_genetic_map_input <- "/work2/genphyse/dynagen/adanguy/croisements/110222/article/gblup/markers_estimated_sTRUE_iESTIMATED_q300rand_h0.4_gGBLUP_pselected_n1_mWE.txt"          
# titre_genotypes_parents_input <- "/work2/genphyse/dynagen/adanguy/croisements/110222/article/parents/genotypes_last_generation_sTRUE_iESTIMATED_q300rand_h0.4_gGBLUP_pselected_n1_mWE.txt"
# nbcores <- 1                                                                                                                                                      
# chr <- "5B"                                                                                                                                                     
# progeny <- "RILsF5"                                                                                                                                                 
# titre_function_calcul_index_variance_crosses <- "/work/adanguy/these/croisements/scripts/calcul_index_variance_crosses.R"                                                                                
# r_big_files <- "/work2/genphyse/dynagen/adanguy/croisements/110222/article/crosses/temp/"                                                                               
# titre_variance_crosses_chr_output <- "/work2/genphyse/dynagen/adanguy/croisements/110222/article/crosses/variance_crosses_sTRUE_iESTIMATED_q300rand_h0.4_gGBLUP_pselected_n1_mWE_5B.txt"      
# titre_lines_input <-  "/work2/genphyse/dynagen/adanguy/croisements/110222/article/parents/GEBV_parents_sTRUE_iESTIMATED_q300rand_h0.4_gGBLUP_pselected_n1_mWE.txt"             
# 
# 



cat("\n\n INPUT : genotyping \n\n")
g <- fread(titre_genotypes_parents_input) 
g %>% select(1:10) %>% head()
g%>% select(1:10) %>% tail()
g%>% dim()




cat("\n\n INPUT : markers info \n\n")
m <- fread(titre_markers_input) %>% arrange(chr, dcum, marker)
head(m)
tail(m)
dim(m)



cat("\n\n INPUT : lines info \n\n")
l <- fread(titre_lines_input)
head(l)
tail(l)
dim(l)


cat("\n\n INPUT : genetic_map \n\n")
genetic_map <- fread(titre_genetic_map_input) %>% arrange(chr, dcum, marker)
head(genetic_map)
tail(genetic_map)
dim(genetic_map)


motif2 <- paste0(unique(l$simulation), "_",
                 unique(l$qtls_info), "_",
                 unique(l$qtls), "_",
                 unique(l$heritability),"_",
                 unique(m$genomic),"_",
                 unique(l$population),"_",
                 unique(l$population_ID),"_",
                 unique(genetic_map$genetic_map),"_",
                 chr)

motif2
                 




backingfile1 <- paste0(r_big_files, "big_matrix_1_",motif2)
backingfile2 <- paste0(r_big_files, "big_matrix_2_",motif2)
backingfile3 <- paste0(r_big_files, "big_matrix_3_",motif2)
backingfile4 <- paste0(r_big_files, "big_matrix_4_",motif2)
backingfile5 <- paste0(r_big_files, "big_matrix_5_",motif2)
backingfile6 <- paste0(r_big_files, "big_matrix_6_",motif2)
backingfile7 <- paste0(r_big_files, "big_matrix_7_",motif2)
backingfile8 <- paste0(r_big_files, "big_matrix_8_",motif2)




source(titre_function_calcul_index_variance_crosses)

### first steps


nind = nrow(g)




# lines ID
liste_lines <- g %>%
  arrange(ID) %>%
  dplyr::select(ID) %>%
  unlist() %>%
  as.vector()

cat("\n\nlist lines\n\n")
length(liste_lines)


################### sepcific of chr

progeny2=as.vector(unlist(strsplit(progeny, split="F")))[1]
k=as.numeric(as.vector(unlist(strsplit(progeny, split="F")))[2])-1


m2 <- m %>% dplyr::select(chr, marker, value) %>%
  inner_join(genetic_map %>% dplyr::select(marker, dcum), by="marker") %>%
  arrange(chr, dcum)


#### vcov

calcul_variance_crosses_chr <- function(chr, progeny, k){
  
  colonnes_geno_chr <- m2 %>%
    arrange(chr, dcum, marker) %>%
    filter(chr==!!chr) %>%
    filter(value !=0) %>%
    dplyr::select(marker) %>%
    unlist() %>%
    as.vector()
  
  
  
  
  nmark_chr=length(colonnes_geno_chr)
  
  
  dgen0 <- m2 %>%
    arrange(chr, dcum, marker) %>%
    filter(chr==!!chr)  %>%
    filter(value !=0)
  
  beta <- m2 %>%
    arrange(chr, dcum, marker) %>%
    filter(chr==!!chr) %>% 
    filter(value !=0) %>%
    dplyr::select(one_of("value")) %>%
    unlist() %>%
    as.vector()
  
  if (nmark_chr >=2){
    
    
    
    dgen <- sapply(1:nrow(dgen0),function(x) abs(dgen0$dcum[x] - dgen0$dcum) ) # for now, dgen is cM/Mb
    r <- 0.5*(1-exp(-2*(dgen/100))) # reciproque of Haldane mapping function gives expected recombination fraction (%). The factor 100 is to convert cM to M
    # expected recombination fraction after k generation of selfing, from Lehermeier & al. 2017
    rk <- ((2*r)/(1+2*r))*(1-0.5^k*(1-2*r)^k)
    
    if (progeny2=="DHs"){
      
      D = (1-(2*rk))/4 # variance-covariance matrix of pairwise locus after k generation of selfing and then doubling
      
    } else if (progeny2=="RILs"){
      
      
      
      
      
      D =  (1 - 2*rk - (0.5^k)*(1-2*r)^k)/4 # variance-covariance matrix of pairwise locus after k generation of selfing 
      diag(D) <- 1/4  # variance at one locus
      
      
    }
    
    
    #print(D[1:min(10, nrow(D)),1:min(10, ncol(D))])
    
    
    
    # D <- sapply(1:nrow(D),function(x) abs(D[x, "dcum"] - D[,"dcum"]) )
    # D <- 0.5*(1-exp(-2*(D/100))) # Haldane mappinf function reciproc
    # D <- (1-2*D)/4
    # diag(D) <- 0.25 
    
    
    # D = variance-covariance matrix of progeny genotype (common to every cross)
    
    suppressWarnings(file.remove(paste0(backingfile1, ".rds"), paste0(backingfile1, ".bk"))) 
    D <- as_FBM(D, backingfile = backingfile1) 
    
    
    
    
    ### D2 = variance-covariance matrix of progeny genotype weighted by QTL effects (common to every cross)
    
    
    
    beta2 <- matrix(rep(0, times=nmark_chr*nmark_chr), ncol=nmark_chr)
    diag(beta2) <- beta #B
    suppressWarnings(file.remove(paste0(backingfile2, ".rds"), paste0(backingfile2, ".bk"))) # should write a warning message
    beta2 <- as_FBM(beta2, backingfile = backingfile2)
    
    suppressWarnings(file.remove(paste0(backingfile3, ".rds"), paste0(backingfile3, ".bk"))) # should write a warning message
    D2 <- FBM(nmark_chr, nmark_chr, backingfile=backingfile3)
    big_apply(D2, a.FUN = function(X, ind) {
      X[,ind] <- crossprod(beta2, D[,ind])
      NULL  }
      , block.size = block_size(1e2,ncores=nbcores), a.combine="c") # B*D
    
    
    big_apply(D2, a.FUN = function(X, ind) {
      X[,ind] <-tcrossprod(D2, beta2[ind,])
      NULL  }
      , block.size = block_size(1e2,ncores=nbcores), a.combine="c") # B*D
    
    
    rm(beta2)
    suppressWarnings(file.remove(paste0(backingfile2, ".rds"), paste0(backingfile2, ".bk"))) # should write a warning message
    
    
    
    
    ###  = genotypes of parents (0,1,2) * QTLs effects (one per parent) = 
    
    
    
    suppressWarnings(file.remove(paste0(backingfile4, ".rds"), paste0(backingfile4, ".bk"))) # should write a warning message
    geno2 <- as_FBM(g %>% arrange(ID) %>% dplyr::select(all_of(colonnes_geno_chr)), backingfile = backingfile4) # fast
    
    
    
    suppressWarnings(file.remove(paste0(backingfile5, ".rds"), paste0(backingfile5, ".bk"))) # should write a warning message
    gamma <- big_transpose(geno2, backingfile = backingfile5) # fast
    #rm(geno2, colonnes_geno_chr)
    suppressWarnings(file.remove(paste0(backingfile4, ".rds"), paste0(backingfile4, ".bk"))) # should write a warning message
    
    
    
    
    # suppressWarnings(file.remove(paste0(backingfile6, ".rds"), paste0(backingfile6, ".bk"))) # should write a warning message
    # beta <- big_copy(gamma,  backingfile = backingfile6) # row = marker, column = individual genotype (0,1,2)
    # big_apply(beta, ind=rows_along(beta), a.FUN = function(X, ind) {
    #   X[ind,] <- beta[ind,]*beta[ind]
    #   NULL  }
    #   , block.size = block_size(1e2, ncores=nbcores), a.combine="c") # row = marker, column = individual. Cell = genotype (0,1,2)*marker effect
    # # fast
    # #rm(beta)
    
    
    
    
    # # mu = gamma_P1 * D * gamma_P1 ' (one per parent)
    # suppressWarnings(file.remove(paste0(backingfile7, ".rds"), paste0(backingfile7, ".bk"))) # should write a warning message
    # mu <- FBM(nrow=1, ncol=nind,  backingfile = backingfile7) # row = marker, column = individual genotype (0,1,2)
    # big_apply(mu, a.FUN = function(X, ind) {
    #   X[,ind] <- diag(tcrossprod(crossprod(as.matrix(beta[,ind]), D), t(beta[,ind])))
    #   NULL  }
    #   , block.size = block_size(1e2,ncores=nbcores), a.combine="c") 
    
    
    # mu = gamma_P1 * D * gamma_P1 ' (one per parent)
    suppressWarnings(file.remove(paste0(backingfile7, ".rds"), paste0(backingfile7, ".bk"))) # should write a warning message
    mu <- FBM(nrow=1, ncol=nind,  backingfile = backingfile7) # row = marker, column = individual genotype (0,1,2)
    big_apply(mu, a.FUN = function(X, ind) {
      X[,ind] <- diag(tcrossprod(crossprod(as.matrix(gamma[,ind]), D2), t(gamma[,ind])))
      NULL  }
      , block.size = block_size(1e2,ncores=nbcores), a.combine="c") 
    
    
    ##### test
    
    
    
    
    
    
    
    
    suppressWarnings(file.remove(paste0(backingfile8, ".rds"), paste0(backingfile8, ".bk"))) # should write a warning message
    t <- FBM(nrow=nind, ncol=nmark_chr,  backingfile = backingfile8) # row = marker, column = individual genotype (0,1,2)
    big_apply(t, ind=rows_along(t), a.FUN = function(X, ind) {
      X[ind,] <- crossprod(gamma[,ind], D2)
      NULL  }
      , block.size = block_size(1e2,ncores=nbcores), a.combine="c") 
    
    
    
    rm(beta, D, D2)
    suppressWarnings(file.remove(paste0(backingfile6, ".rds"), paste0(backingfile6, ".bk"))) # should write a warning message
    suppressWarnings(file.remove(paste0(backingfile3, ".rds"), paste0(backingfile3, ".bk"))) # should write a warning message
    suppressWarnings(file.remove(paste0(backingfile1, ".rds"), paste0(backingfile1, ".bk"))) # should write a warning message
    
    
    
    
    
    
    index2 <- lapply(1:ncol(gamma), function(x) as.vector(which(gamma[,x]==2)))
    index1 <- lapply(1:ncol(gamma), function(x) as.vector(which(gamma[,x]==1)))
    rm(gamma)
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
    
    
    
  } else if (nmark_chr==1) { # only one qtl on the chromosome
    
    
    
    
    
    lines_to_keep <- calcul1(nind)
    
    
    gamma <- g %>% arrange(ID) %>% dplyr::select(ID, colonnes_geno_chr) %>% as.data.frame()
    
    variance <- matrix(outer(gamma[,colonnes_geno_chr], gamma[,colonnes_geno_chr], "-"), ncol=1)[lines_to_keep,]
    
    variance <- abs(variance)
    
    variance[which(variance==2)] <- beta*beta
    variance[which(variance==1)] <- beta*beta*0.75
    variance[which(variance==0)] <- 0
    
    
    
    
    
    
    
    
    
    
  } else {
    
    variance=0
  }
  
  return(variance)
  
  
  
}



variance_temp <- calcul_variance_crosses_chr(chr=chr, k=k, progeny=progeny2)
  
  
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
  vf <- data.frame(P1=crosses_names$P1,
                    P2=crosses_names$P2,
                    variance=variance_temp) %>%
    mutate(variance=ifelse(variance < 0, 0, variance)) %>% 
    mutate(marker=!!m$marker[1]) %>%
    inner_join(m %>% dplyr::select(one_of("marker", "genomic")), by="marker") %>%
    mutate(temp=!!l$ID[1]) %>%
    inner_join(l %>% dplyr::select(-one_of("value", "info", "genomic")), by=c("temp"="ID")) %>%
    mutate(progeny=!!progeny) %>%
    mutate(genetic_map=!!unique(genetic_map$genetic_map)) %>%
    mutate(chr=!!chr) %>%
    arrange(P1, P2) %>%
    dplyr::select(P1, P2, variance, chr, genetic_map, simulation, qtls, qtls_info, heritability, genomic, population, progeny, population_ID, progeny)




cat("\n\nOUTPUT : variance of crosses \n\n")
head(vf)
tail(vf)
dim(vf)
write_delim(vf, titre_variance_crosses_chr_output, col_names = T, delim="\t", append = F, na="NA", quote_escape="none")




sessionInfo()
