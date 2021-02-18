

Sys.time()
cat("\n\nafter_blupf90.R\n\n")
rm(list = ls())
graphics.off()
set.seed(1)

suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(compiler))
suppressPackageStartupMessages(library(MASS))
suppressPackageStartupMessages(library(qvalue))


titre_geno <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/genotyping_matrix_filtered_imputed.txt"
IBD <- 0.25

geno <- fread(titre_geno) %>% dplyr::select(-line2) %>% as.matrix()


lines <- fread(titre_geno, select = 1) %>% unlist() %>% as.vector()
nmark <- ncol(geno) -1

d <- data.frame()

for (i in 1:(nrow(geno)-1)){
  
  geno_i = geno[i,-1]
  P1=lines[i]
  
  for (j in (i+1):nrow(geno)) {
    
    
    d <- rbind(d, data.frame( P1=P1, P2=lines[j], distance=sum(abs(geno_i - geno[j,-1]))/(nmark*2)))
    
    
    
  }
}
d
d$inbreeding=1-d$distance

inbreeding_treshold <- (coefficients(rlm(d$inbreeding~1)))*(1+IBD)
hist(d$inbreeding)

q1 <- qvalue(pnorm(d$inbreeding, mean=0.6541274 , sd=0.0283, lower.tail = F))$qvalue
hist(q1)
d[which(q1 <= 0.05),] %>% arrange(inbreeding) %>% head()

d %>% filter(P1=="AO15011_XXX00000000000000000" & P2=="AO15018_XXX00000000000000000")

hist(d$inbreeding)




d[which(d$distance <= lower_treshold),]
      