


# Goal : filter genotyping dataset
# Input : genotyping matrix, id of lines
# Output : updated genotyping matrix



Sys.time()
cat("\n\nfiltering_genotyping_matrix.R\n\n")
rm(list = ls())
graphics.off()
set.seed(1)

suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(compiler))



variables <- commandArgs(trailingOnly=TRUE)
cat("\n\nVariables : \n")
print(variables)
cat("\n\n")



titre_genotyping_matrix_raw <- variables[1]
titre_lines <- variables[2]
titre_genotyping_matrix_updated <- variables[3]
keep_all <- variables[4]





# 

# titre_genotyping_matrix_raw <- "/work/adanguy/these/croisements/amont/matrix_nonimput_withoutOTV_names.txt"
# titre_lines <- "/work/adanguy/these/croisements/180120/lines.txt"
# titre_genotyping_matrix_updated <- "/work/adanguy/these/croisements/180120/genotyping_matrix.txt"



### Chargement des donnees


cat("\n\n INPUT : genotyping matrix to have markers ID \n\n")
genotyping <- suppressWarnings(fread(titre_genotyping_matrix_raw))
genotyping[1:10, 1:10]
dim(genotyping)
# subsampling of data for trials
# genotyping <- genotyping[,sort(c(1, sample(1:ncol(genotyping), size=2000, replace=F)))] 
# genotyping <- replace(genotyping, is.na(genotyping), 0)
# column 1 = V1 = variery ID (string, as many levels as the row number, here 2 143)
# column 2 - 31 315 = AX.1234567 = marker ID (intergers), here 31 315 markers
# dimension of file : 2 143 * 31315
# Don't worry with warning message

cat("\n\n INPUT : new ID of varieties with a uniform format \n\n")
lines <- fread(titre_lines)
head(lines)
dim(lines)
# column 1 = LINE = ID of variety (string, 3 185 levels = as many as varieties ID)
# column 2 = line2 = modified ID of variety (use in further analysis) (string, 3 185 levels)
# column 3 = phenotyped = variety phenotyped  (logical)
# column 4 = blue = estimate of variety yield (numeric)
# column 5 = genotyped = variety was genotyped (logical)
# column 6 = used_as_parent = variety used as parent (logical but NA for now)
# dim file : 3185*6



# STEP 1 : keep only lines which have BLUEs

if (keep_all=="TRUE"){

genotyping2 <- genotyping %>% rename(LINE=V1) %>%
  inner_join(lines %>% filter(genotyped==T) %>% dplyr::select(LINE, line2), by="LINE") %>% 
  dplyr::select(-LINE) %>%
  dplyr::select(line2, starts_with("AX")) %>%
  arrange(line2)

} else if (keep_all=="FALSE"){
  
  genotyping2 <- genotyping %>% rename(LINE=V1) %>%
    inner_join(lines %>% filter(genotyped==T & phenotyped==T) %>% dplyr::select(LINE, line2), by="LINE") %>% 
    dplyr::select(-LINE) %>%
    dplyr::select(line2, starts_with("AX"))%>%
    arrange(line2)
  
  
}








# STEP 2 : filtering SNP dataset

taux_het_max <- 0.05
taux_NA_max <- 0.05
maf_min <- 0.05





snp_pas_ok <- data.frame(temp=1)
lines_pas_ok <- data.frame(temp=1)
i=0

while(nrow(snp_pas_ok) >=1 | nrow(lines_pas_ok)>=1){
  
  i=i+1
  print(paste0("filtering stage ", i))
  
  
  # SNP
  
  # minor allele frequency
  
  homo1 <- apply(genotyping2[,-1], 2, function(x) length(which(x =="1")))
  hetero <- apply(genotyping2[,-1], 2, function(x) length(which(x =="0")))
  homo2 <- apply(genotyping2[,-1], 2, function(x) length(which(x =="-1")))
  maf <- (2*homo1 + hetero)/(2*homo1 + 2*hetero + 2*homo2)
  maf_ok <- names(which(maf <= 1-maf_min & maf >= maf_min))
  maf_pas_ok <- data.frame(snp=names(which(maf > 1-maf_min | maf < maf_min)), maf=round(maf[which(maf > 1-maf_min | maf < maf_min)], digits=2))
  
  # missing value
  
  missing_value <- (nrow(genotyping2) - homo1 - hetero - homo2)/nrow(genotyping2)
  missing_value_ok <- names(which(missing_value <= taux_NA_max))
  missing_value_pas_ok <- data.frame(snp=names(which(missing_value > taux_NA_max)), taux_NA=round(missing_value[which(missing_value > taux_NA_max)], digits=2))
  
  # heterozygotie
  
  hetero_value <- hetero/(homo1+hetero+homo2)
  hetero_ok <- names(which(hetero_value <= taux_het_max))
  hetero_pas_ok <- data.frame(snp=names(which(hetero_value > taux_het_max)), taux_het=round(hetero_value[which(hetero_value>taux_het_max)], digits=2))
  
  cat("\n\n SNP removed, either because of too much missing values or too high heterozygotie rate or too extreme MAF \n\n")
  snp_pas_ok <- maf_pas_ok %>% full_join(missing_value_pas_ok, by="snp") %>%
    full_join(hetero_pas_ok, by="snp") %>%
    arrange(snp)
  snp_pas_ok
  print(nrow(snp_pas_ok))
  
  
  snp_to_keep <- intersect(intersect(maf_ok, missing_value_ok), hetero_ok)
  
  genotyping2 <- genotyping2[,c(1,which(colnames(genotyping2) %in% snp_to_keep))]
  
  
  
  # individual
  
  
  
  # missing value
  
  homo1 <- apply(t(genotyping2[,-1]), 2, function(x) length(which(x =="1")))
  hetero <- apply(t(genotyping2[,-1]), 2, function(x) length(which(x =="0")))
  homo2 <- apply(t(genotyping2[,-1]), 2, function(x) length(which(x =="-1")))
  missing_value <- (ncol(genotyping2[,-1]) - homo1 - hetero - homo2)/ncol(genotyping2[,-1])
  missing_value_ok <- genotyping2$line2[which(missing_value <= taux_NA_max)]
  missing_value_not_ok <- genotyping2$line2[which(missing_value > taux_NA_max)]
  d1 <- data.frame(line2=as.character(missing_value_not_ok), taux_NA=round(missing_value[which(missing_value > taux_NA_max)], digits=2))
  
  
  # heterozygotie
  
  homo1 <- apply(t(genotyping2[,-1]), 2, function(x) length(which(x =="1")))
  hetero <- apply(t(genotyping2[,-1]), 2, function(x) length(which(x =="0")))
  homo2 <- apply(t(genotyping2[,-1]), 2, function(x) length(which(x =="-1")))
  hetero_value <- hetero/(homo1+hetero+homo2)
  hetero_ok <- genotyping2$line2[which(hetero_value <= taux_het_max)]
  hetero_not_ok <- genotyping2$line2[which(hetero_value > taux_het_max)]
  d2 <- data.frame(line2=as.character(hetero_not_ok), taux_het=round(hetero_value[which(hetero_value > taux_het_max)], digits=2))
  cat("\n\n Lines removed, either because of too much missing values or too high heterozygotie rate \n\n")
  lines_pas_ok <- d1 %>% full_join(d2, by="line2") %>% arrange(line2)
  lines_pas_ok
  print(nrow(lines_pas_ok))
  line2_to_keep <- intersect(missing_value_ok, hetero_ok)
  
  
  
  
  genotyping2 <- genotyping2[which(genotyping2$line2 %in% line2_to_keep),]
  
  
  
  
  cat("\n\n dimension of filtered file \n\n")
  print(dim(genotyping2))
}



### STEP 3 : ensurring alternativ (1) and reference (-1) alleles. It means that 0,1,2 is dosage of alternativ alleles

homo1 <- apply(genotyping2[,-1], 2, function(x) length(which(x ==1)))
homo_1 <- apply(genotyping2[,-1], 2, function(x) length(which(x ==-1)))

dom <- data.frame(homo1=homo1, homo_1=homo_1) %>%
  rowwise() %>%
  mutate(ref=max(homo1, homo_1)) %>%
  mutate(good=ifelse(ref==homo_1, T, F)) %>%
  ungroup() %>%
  mutate(SNP=colnames(genotyping2)[-1])


genotyping2bis <- genotyping2[,c(1,which(dom$good==T)+1)]
genotyping2ter <- - genotyping2[,which(dom$good==F)+1]


genotyping2 <- cbind(genotyping2bis, genotyping2ter)


### preprare for print

genotyping3 <- genotyping2 %>%  
  dplyr::select(line2, everything()) %>%
  arrange(line2) %>%
  mutate_at(vars(starts_with("AX")), funs(as.integer(as.character(.)))) %>%
  mutate_if(is.integer,~.+1) 
colnames(genotyping3) <- str_replace_all(colnames(genotyping3), "AX.","AX-")

lines2 <- lines %>% mutate(used_as_parent=line2 %in% genotyping2$line2) %>% arrange(line2)






cat("\n\n OUTPUT : gentyping matrix updated \n\n")
genotyping3[1:10,1:10]
dim(genotyping3)
# column 1 = line 2 = modified ID for variety (string, as many levels as number of lines, i.e. 2089)
# column 2 - 19751 = genotype at each SNP
# dimension: 2089 * 19821
write.table(genotyping3, titre_genotyping_matrix_updated, col.names = T, row.names = F, quote=F, dec=".", sep="\t")





cat("\n\n OUTPUT : correspondance between true ID and modified ID of lines \n\n")
head(lines2)
dim(lines2)
write.table(lines2, titre_lines, col.names = T, row.names = F, dec=".", sep="\t", quote=F)
# column 1 = LINE = ID of variety (string, 3 185 levels = as many as varieties ID)
# column 2 = line2 = modified ID of variety (use in further analysis) (string, 3 185 levels)
# column 3 = phenotyped = variety phenotyped  (logical)
# column 4 = blue = estimate of variety yield (numeric)
# column 5 = gebv
# column 6 = genotyped = variety was genotyped (logical)
# column 7 = used_as_parent = variety used as parent (logical)
# dim file : 3185*6



sessionInfo()

