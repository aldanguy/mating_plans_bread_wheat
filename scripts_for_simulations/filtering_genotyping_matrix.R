


# Goal : remove markers and lines with too much NA or heterozygotie. Formatting genotyping data
# Input : genotyping matrix, ID of lines
# Output : formatted genotyping matrix



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



titre_genotyping_input <- variables[1]
titre_lines_input <- variables[2]
keep_all <- variables[3]
titre_genotyping_output <- variables[4]
titre_lines_output <- variables[5]




# 

# titre_genotyping_matrix_raw <- "/work/adanguy/these/croisements/amont/matrix_nonimput_withoutOTV_names.txt"
# titre_lines <- "/work2/genphyse/dynagen/adanguy/croisements/150221/prepare/lines.txt"
# titre_genotyping_matrix_updated <- "/work/adanguy/these/croisements/180120/genotyping_matrix.txt"
# 
# keep_all <- "FALSE"

### Chargement des donnees


cat("\n\n INPUT : genotyping data \n\n")
suppressWarnings(fread(titre_genotyping_input)) %>% arrange(V1) %>% select(1:10) %>% slice(1:10)
suppressWarnings(fread(titre_genotyping_input)) %>% arrange(V1) %>% select(1:10) %>% slice((nrow(.)-10) : nrow(.))
suppressWarnings(fread(titre_genotyping_input)) %>% dim()



cat("\n\n INPUT : lines info \n\n")
fread(titre_lines_input) %>% head()
fread(titre_lines_input) %>% tail()
fread(titre_lines_input) %>% filter(phenotyped==T & genotyped==T) %>% head()
fread(titre_lines_input) %>% dim()




# STEP 1 : keep only lines which have BLUEs or keep all

if (keep_all=="TRUE"){
  
  genotyping2 <- suppressWarnings(fread(titre_genotyping_input))  %>% rename(LINE=V1) %>%
    inner_join(fread(titre_lines_input) %>% filter(genotyped==T) %>% dplyr::select(LINE, ID), by="LINE") %>% 
    dplyr::select(-LINE) %>%
    dplyr::select(ID, starts_with("AX")) %>%
    arrange(ID)
  
} else if (keep_all=="FALSE"){
  
  genotyping2 <- suppressWarnings(fread(titre_genotyping_input))  %>% rename(LINE=V1) %>%
    inner_join(fread(titre_lines_input) %>% filter(genotyped==T & phenotyped==T) %>% dplyr::select(LINE, ID), by="LINE") %>% 
    dplyr::select(-LINE) %>%
    dplyr::select(ID, starts_with("AX"))%>%
    arrange(ID)
  
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
  
  # filtering
  snp_to_keep <- intersect(intersect(maf_ok, missing_value_ok), hetero_ok)
  genotyping2 <- genotyping2[,c(1,which(colnames(genotyping2) %in% snp_to_keep))]
  
  
  
  # individual
  
  # missing value
  
  homo1 <- apply(t(genotyping2[,-1]), 2, function(x) length(which(x =="1")))
  hetero <- apply(t(genotyping2[,-1]), 2, function(x) length(which(x =="0")))
  homo2 <- apply(t(genotyping2[,-1]), 2, function(x) length(which(x =="-1")))
  missing_value <- (ncol(genotyping2[,-1]) - homo1 - hetero - homo2)/ncol(genotyping2[,-1])
  missing_value_ok <- genotyping2$ID[which(missing_value <= taux_NA_max)]
  missing_value_not_ok <- genotyping2$ID[which(missing_value > taux_NA_max)]
  d1 <- data.frame(ID=as.character(missing_value_not_ok), taux_NA=round(missing_value[which(missing_value > taux_NA_max)], digits=2))
  
  
  # heterozygotie
  
  homo1 <- apply(t(genotyping2[,-1]), 2, function(x) length(which(x =="1")))
  hetero <- apply(t(genotyping2[,-1]), 2, function(x) length(which(x =="0")))
  homo2 <- apply(t(genotyping2[,-1]), 2, function(x) length(which(x =="-1")))
  hetero_value <- hetero/(homo1+hetero+homo2)
  hetero_ok <- genotyping2$ID[which(hetero_value <= taux_het_max)]
  hetero_not_ok <- genotyping2$ID[which(hetero_value > taux_het_max)]
  d2 <- data.frame(ID=as.character(hetero_not_ok), taux_het=round(hetero_value[which(hetero_value > taux_het_max)], digits=2))
  cat("\n\n Lines removed, either because of too much missing values or too high heterozygotie rate \n\n")
  lines_pas_ok <- d1 %>% full_join(d2, by="ID") %>% arrange(ID)
  lines_pas_ok
  print(nrow(lines_pas_ok))
  ID_to_keep <- intersect(missing_value_ok, hetero_ok)
  
  
  
  # filtering
  genotyping2 <- genotyping2[which(genotyping2$ID %in% ID_to_keep),]
  

  cat("\n\n dimension of genotyping \n\n")
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

genotyping2 <- genotyping2 %>%  
  dplyr::select(ID, everything()) %>%
  arrange(ID) %>%
  mutate_at(vars(starts_with("AX")), funs(as.integer(as.character(.)))) %>%
  mutate_if(is.integer,~.+1) 
colnames(genotyping2) <- str_replace_all(colnames(genotyping2), "AX.","AX-")

lines2 <- fread(titre_lines_input) %>% mutate(used_as_parent= ID %in% genotyping2$ID) %>% 
  filter(used_as_parent==T) %>% 
  arrange(ID) %>%
  mutate(type="pheno") %>%
  mutate(sim="FALSE") %>%
  mutate(qtls=NA) %>%
  mutate(h=NA) %>%
  mutate(r=NA) %>%
  mutate(g=NA) %>%
  dplyr::select(ID, value, type, sim, qtls, h, r,g)


cat("\n\n OUTPUT : genotyping \n\n")
genotyping2[1:10,1:10]
genotyping2[((nrow(genotyping2)-10):nrow(genotyping2)),1:10]
dim(genotyping2)
write.table(genotyping2, titre_genotyping_output, col.names = T, row.names = F, quote=F, dec=".", sep="\t")


cat("\n\n OUTPUT : lines info \n\n")
head(lines2)
tail(lines2)
dim(lines2)
write.table(lines2, titre_lines_output, col.names = T, row.names = F, dec=".", sep="\t", quote=F)



sessionInfo()

