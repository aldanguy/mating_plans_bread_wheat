


Sys.time()
cat("\n\nverify_covariance_locus.R\n\n")
rm(list = ls())
graphics.off()
set.seed(1)
t1 <- Sys.time()

suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(compiler))
suppressPackageStartupMessages(library(parallel))


titre_geno <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/genotyping_sd_predictions.txt"
titre_markers <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/markers_filtered_subset_estimated.txt"
titre_echant <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/echant.txt"

markers <- fread(titre_markers)
geno <- fread(titre_geno, skip=841, nrows=400) %>% as.data.frame() 
geno <- geno[, c(3:19752)]

genop <- fread(titre_geno, nrows=841, fill=T) %>% as.data.frame()

#### 1000 couples de locus entre chr



ordre <- markers %>%
  arrange(chr, pos) %>%
  dplyr::select(marker) %>%
  unlist() %>%
  as.vector()

genop <- genop %>% as.data.frame() %>%
  dplyr::select(-run) %>%
  filter(ID == "ALTIGO_XXX000000000000000000" | ID == "AO06313_XXX00000000000000000" )%>%
  dplyr::select(-ID)

# unique(diff(match(ordre, colnames(genop))))




m <- markers %>%
  group_by(chr) %>%
  slice(sample(1:n(), size=20, replace=F)) %>%
  ungroup() %>%
  arrange(chr, pos) %>%
  dplyr::select(marker) %>%
  unlist() %>%
  as.vector()


#pos <- sort(which(markers$marker %in% m))
#noms_colonnes <- paste0("V", pos)
# geno <- geno %>% dplyr::select(one_of(noms_colonnes)) %>% as.data.frame()
# genop <- genop %>% dplyr::select(ID, one_of(m)) %>% as.data.frame() %>%
#   filter(ID == "ALTIGO_XXX000000000000000000" | ID == "AO06313_XXX00000000000000000" )


echant <- expand_grid(M1=m, M2=m) %>%
  filter(M1 != M2) %>%
  inner_join(markers %>% mutate(index=1:n()) %>% dplyr::select(chr, marker, dcum_WE, index), by=c("M1"="marker")) %>%
  rename(index.M1=index, chr.M1=chr, dcum.M1=dcum_WE) %>%
  inner_join(markers %>% mutate(index=1:n()) %>% dplyr::select(chr, marker, dcum_WE, index), by=c("M2"="marker")) %>%
  rename(index.M2=index, chr.M2=chr, dcum.M2=dcum_WE) %>%
  filter(index.M1 < index.M2) %>%
  dplyr::select(M1, M2, chr.M1, chr.M2, dcum.M1, dcum.M2) %>%
  arrange(chr.M1, dcum.M1, chr.M2, dcum.M2) %>%
  mutate(same_chr=ifelse(chr.M1==chr.M2, T, F)) %>%
  mutate(d_gen_cM=abs(dcum.M2 -dcum.M1)) %>%
  mutate(r=0.5*(1-exp(-2*(d_gen_cM/100))) ) %>%
  mutate(r=ifelse(same_chr==T,r, 0.5)) %>%
  mutate(cov_expected=(1-2*r)/4) 

markers2 <- markers %>% arrange(chr, pos) %>% dplyr::select(marker) %>% unlist() %>% as.vector()
i=8191
covariances <- as.numeric()
LOD_score <- as.numeric()
variance_observed <- as.numeric()
variance_expected <- as.numeric()
for (i in 1:nrow(echant)) {
  print(i)
  
  mkrs <- c(echant$M1[i], echant$M2[i])
  
  pos <- paste0("V",sort(which(markers2 %in% mkrs)))
  
  
  if (length(unique(geno[,pos[1]]))>=2 | length(unique(geno[,pos[2]])) >=2) {
    
    
    genop2 <- genop[,mkrs] %>% unique %>% mutate(P=1:n()) 
    colnames(genop2) <- c("m1", "m2", "P")
    
    covariance_temp <- cov(geno[,pos[1]], geno[,pos[2]]) %>% as.vector()
    
    d <- data.frame(m1=geno[,pos[1]], m2=geno[,pos[2]]) %>% group_by(m1,m2) %>%
      summarise(n=n()) %>%
      arrange(desc(n)) %>%
      ungroup() %>%
      as.data.frame() %>%
      full_join(genop2, by=c("m1"="m1", "m2"="m2")) %>%
      arrange(P)
    
    
    if (d %>% filter(m1==0 & m2==0) %>% nrow() !=1){
      
      d <- rbind(d, data.frame(m1=0, m2=0, n=0, P=NA))
    }
    
    if (d %>% filter(m1==0 & m2==2) %>% nrow() !=1){
      
      d <- rbind(d, data.frame(m1=0, m2=2, n=0, P=NA))
    }
    
    if (d %>% filter(m1==2 & m2==0) %>% nrow() !=1){
      
      d <- rbind(d, data.frame(m1=2, m2=0, n=0, P=NA))
    }
    
    if (d %>% filter(m1==2 & m2==2) %>% nrow() !=1){
      
      d <- rbind(d, data.frame(m1=2, m2=2, n=0, P=NA))
    }
    
    
    if (length(unique(geno[,pos[1]]))>=2 & length(unique(geno[,pos[2]])) >=2) {
      
    
    
    r=echant$r[i]
    
    # A quel point on s'éloigne du 50 %?
    H1 <- dmultinom(x=c(d$n[1], d$n[2], d$n[3], d$n[4]), prob=c(d$n[1]/400, d$n[2]/400, d$n[3]/400, d$n[4]/400))
    # equivalent à
    # H1 <- choose(nb_A + nb_B, nb_A)*taux_A^nb_A*(1-taux_A)^nb_B
    H0 <-  dmultinom(x=c(d$n[1], d$n[2], d$n[3], d$n[4]), prob=c((1-r)/2, (1-r)/2, r/2, r/2))
    
    
    LOD_score_temp <- log10(H1/H0)
    
    
    
 
    
  } else {
    
    covariance_temp <- NA
    LOD_score_temp <- NA
 
  }
    
    
    
  
  
  D <- matrix(c(0.25, echant$cov_expected[i], echant$cov_expected[i], 0.25), ncol=2, byrow=F)
  #D <- matrix(c(0.25, 0.236*4, 0.236*4, 0.25), ncol=2, byrow=F)
  effet1=markers %>% filter(marker %in% mkrs) %>% slice(1) %>% dplyr::select(snp_effect) %>% unlist() %>% as.vector()
  effet2=markers %>% filter(marker %in% mkrs) %>% slice(2) %>% dplyr::select(snp_effect) %>% unlist() %>% as.vector()
  
  B1=c(d[1,1]*effet1, d[1,2]*effet2)
  B2=c(d[2,1]*effet1, d[2,2]*effet2)
  variance_expected_temp <- tcrossprod(crossprod(as.matrix((B1-B2)),D), t(as.matrix(B1-B2)))
  variance_observed_temp <- var(geno[,pos[1]]*effet1+geno[,pos[2]]*effet2)
  
  } else {
    
    variance_expected_temp <- NA
    variance_observed_temp <- NA
    covariance_temp <- NA
    LOD_score_temp <- NA
    
  }
  
  
  
  covariances <- c(covariances, covariance_temp)
  LOD_score <- c(LOD_score, LOD_score_temp)
  variance_observed <- c(variance_observed,variance_observed_temp)
  variance_expected <- c(variance_expected,variance_expected_temp)
  
}

echant$cov_observed <- covariances
echant$LOD_score <- LOD_score
echant$variance_observed <- variance_observed
echant$variance_expected <- variance_expected

write.table(echant, titre_echant, col.names = T, row.names = F, dec=".", sep="\t", quote=F)
echant <- fread(titre_echant)
head(echant)


echant2 <- echant
echant <- echant %>% dplyr::select(-dcum.M1, -dcum.M2)

# covariance of locus from different chr. Should be equal to 0

ggplot(echant %>% filter(same_chr==F) %>% na.omit(), aes(x = cov_observed)) + geom_histogram() +
  geom_vline(xintercept=0, col="red") +
  xlab("covariance observed between pairs of locus from different chr") +
  ggtitle("Verification of predicted variance of progeny")

# Notice deviation from expectation (0), beacuse values range between -0.2 and 0.2
# Is this significant ?
# LOD_score = log10(H1/H0)
# H0 = probability to obtain observed frequencies (N00, N02, N20, N22) if probability of each class=0.25
# H1 = probability to obtain observed frequencies  if probabilities are different from 0.25
# LOD_score = how higher probable is H1 compare to H0


ggplot(echant %>% filter(same_chr==F) %>% na.omit(), aes(x = cov_observed, y=LOD_score)) + geom_point() +
  xlab("covariance observed between pairs of locus from different chr") +
  ylab("Deviation from expectation (LOD_score)") +
  ggtitle("Verification of predicted variance of progeny")+
  scale_y_continuous(trans='log10') +
  geom_hline(yintercept = 3, col="red")

# Few outliers = all associated with locus "AX-89406995 (muted ?)
echant %>% filter(same_chr==F) %>% na.omit() %>% nrow()
# 8 620 pairs of locus considered
echant %>% filter(same_chr==F) %>% na.omit() %>% filter(LOD_score >=3) %>%nrow()
# 136 pairs deviates significantly from expectation, ie locus do not segregate idependently
# Noticed that locus "AX-89406995" was problematic. Once removed, only 8 locus ont 8492 devidate from expectation
echant %>% filter(same_chr==F) %>% na.omit() %>% filter(M1 != "AX-89406995" & M2 != "AX-89406995") %>% filter(LOD_score >=3) %>%nrow()

echant %>% filter(same_chr==F)  %>% arrange(desc(abs(cov_observed))) %>% na.omit()

# variance of progeny using only two locus
ggplot(echant %>% filter(same_chr==F) %>% na.omit() %>% filter(M1 != "AX-89406995" & M2 != "AX-89406995"), 
       aes(y = variance_observed, x=variance_expected, col=LOD_score)) + 
  geom_point() +
  geom_abline(slope=1, intercept = 0, col="red")+
  xlab("Predicted variance of progenies") +
  ylab("Observed variance of progenies")
# not really good
# Related to inaccuracy of covariance ?


echant %>% filter(same_chr==F) %>% na.omit() %>% filter(M1 != "AX-89406995" & M2 != "AX-89406995") %>%
  filter(variance_observed > 2*variance_expected &variance_expected > 2.5e-5 ) %>%
  head()

###### Covariance between two locus on the same chr
ggplot(echant %>% filter(same_chr==T) %>% na.omit(), aes(x=cov_expected, y = cov_observed, col=LOD_score)) + geom_point() +
  xlab("covariance expected") +
  ylab("covariance observed")

# Notice once more few outliers ( observed ~ 0 while expected >>0). All related to locus "AX-89406995 (muted ?)

# changing sign
ggplot(echant %>% filter(same_chr==T) %>% na.omit()%>% filter(M1 != "AX-89406995" & M2 != "AX-89406995"), aes(x=cov_expected, y = abs(cov_observed), col=LOD_score)) + geom_point() +
  xlab("covariance expected") +
  ylab("covariance observed") +
  geom_abline(slope = 1, intercept = 0, col="red")

# Notice that observed is 4 times higher than predicted
# It seems to be taken into account when computing variance = (B1 - B2)*D*(B1-B2)' with D = 0.25 on diagonal and (1-2r)/4 out of diagonal



ggplot(echant %>% filter(same_chr==T) %>% na.omit() %>% filter(M1 != "AX-89406995" & M2 != "AX-89406995"), 
       aes(y = variance_observed, x=variance_expected, col=LOD_score)) + 
  geom_point() +
  geom_abline(slope=1, intercept = 0, col="red")+
  xlab("Predicted variance of progenies") +
  ylab("Observed variance of progenies")


# About deviaton from expectation
ggplot(echant %>% filter(same_chr==T) %>% na.omit() %>% filter(M1 != "AX-89406995" & M2 != "AX-89406995"), aes(x = cov_observed, y=LOD_score)) + geom_point() +
  xlab("covariance observed between pairs of locus from different chr") +
  ylab("Deviation from expectation (LOD_score)") +
  ggtitle("Verification of predicted variance of progeny")+
  scale_y_continuous(trans='log10') +
  geom_hline(yintercept = 3, col="red")
## all good

# good



# Conclusion
# No big source of error detected
# signs and factor 4 seems to be taken into account when computing variance of progeny with formula
# remove possibility of mutations in MOBPS