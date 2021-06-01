
Sys.time()
cat("\n\nprepare_maize.R\n\n")
rm(list = ls())
graphics.off()
set.seed(1)

suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(compiler))
suppressPackageStartupMessages(library(synbreed))



variables <- commandArgs(trailingOnly=TRUE)
cat("\n\nVariables : \n")
print(variables)
cat("\n\n")


titre_genotyping <- variables[1]
titre_map <- variables[2]
titre_correspondance_ID <- variables[3]
titre_pheno <- variables[4]
titre_function_sort_genotyping_matrix <- variables[5]
nbcores <- as.numeric(variables[6])
titre_genotyping_output <- variables[7]
titre_markers_output <- variables[8]
titre_pheno_output <- variables[9]
 
  # titre_genotyping <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/GSE50558_CFD_matrix_GEO.txt"
  # titre_map <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/Complete-map-3133142.txt"
  # titre_correspondance_ID <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/GPL17677-31783.txt"
  # titre_function_sort_genotyping_matrix <- "/home/adanguydesd/Documents/These_Alice/croisements/scripts/sort_genotyping_matrix_maize.R"
  # nbcores=1
  # titre_pheno <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/genetics.114.161943-17/PhenotypicDataDent.csv"
  # 


source(titre_function_sort_genotyping_matrix)


cat("\n\n genetic map info \n\n")
m <- fread(titre_map, sep=" ")
head(m)
tail(m)
dim(m)

cat("\n\n marker info \n\n")
c <- fread(titre_correspondance_ID)
head(c)
tail(c)
dim(c)


cat("\n\n genotyping info \n\n")
g <- fread(titre_genotyping )
g %>% dplyr::select(1:10) %>% head()
g %>% dplyr::select(1:10) %>% tail()
g %>% dim()




############# phenotypes


p <- fread(titre_pheno) 
cat("\n\n pheno info \n\n")
head(p)
tail(p)
dim(p)


mod <- lm(DMY ~ Genotype + LOC+ IncBlockNo. + Rep + Genotype:LOC, data=p)



pheno <- as.data.frame(coefficients(mod)) %>%
  rownames_to_column("ID") %>%
  filter(grepl("Genotype", ID)) %>%
  filter(!grepl(":", ID)) %>%
  mutate(ID=gsub("Genotype","",ID)) %>%
  mutate(ID=gsub("-","_", ID)) %>%
  arrange(ID) %>%
  mutate(type="pheno") %>%
  mutate(sim=F) %>%
  mutate(qtls=NA) %>%
  mutate(h=NA) %>%
  mutate(r=NA) %>%
  mutate(g=NA) 


colnames(pheno)[2] <- "value"

#############################


m <- fread(titre_map, sep=" ")[,1:5]
colnames(m) <- c("chr", "marker","dcum", "to_remove1", "to_remove2" )
m <- m %>% dplyr::select(chr, marker, dcum)


c <- c[,c(1,3, 5, 6)] %>%
  rename(marker_ID2=ID, marker=RSID, pos=B73_v2_BP) 

m <- m %>% inner_join(c, by=c("marker")) %>%
  filter(chr == B73_v2_chr) %>% # remove chr inconsistance bewteen genetic and physical maps
  group_by(chr, pos) %>%
  slice(1) %>% #remove duplicated pos
  ungroup() %>%
  dplyr::select(chr, marker, pos, dcum, marker_ID2) %>%
  arrange(chr,pos)

rm(c)


columns <- colnames(g)
columns_to_keep <- grep("Allele", columns , invert = T)

g <- g %>% dplyr::select(!!columns_to_keep) %>%
  rename(marker_ID2=ID_REF) %>%
  filter(marker_ID2 %in% m$marker_ID2) %>%
  inner_join(m, by=c("marker_ID2")) %>%
  dplyr::select(-marker_ID2) %>%
  dplyr::select(chr, pos, dcum , marker, everything()) %>% 
  arrange(chr, dcum, pos)


# set NA to markers with individual score <= 0.7

columns <- colnames(g)
g3 <- data.frame(test=rep(NA, times=nrow(g)))
for ( i in sort(grep("Score", columns ))){
  
  
  
  genotypes <- g[,i-1]
  scores <- g[,i]
  theta <- g[,i+1]
  r <- g[,i+2]
  
  
  genotypes[which(scores <= 0.7 | (theta >= 0.1& theta <= 0.9))] <- NA
  
  genotypes[which(!genotypes%in% c("AA","BB"))] <- NA
  
  genotypes <- ifelse(genotypes == "AA", 0, ifelse(genotypes=="BB", 2, ifelse(genotypes %in% c("AB", "BA"), NA, NA))) # DH cannot be heterozygous
  
  g3 <- cbind(g3,data.frame(genotypes))
  
}


# extract names and update to have same lenght
ind_names <- gsub("-", "_", unique(unlist(strsplit(columns[grep("Score", columns)], split="[.]"))[seq(1,1000000, 2)]) %>% na.omit())

colnames(g3) <- c("test", ind_names) %>% na.omit()
# remove marker with %missing data


pheno <- pheno %>% filter(ID %in% colnames(g))

g <- g3 %>%
  dplyr::select(-test) %>%
  cbind(., g %>% dplyr::select(chr, pos, dcum, marker)) %>%
  dplyr::select(chr, pos, dcum, marker, all_of(pheno$ID))

rm(g3)

taux_NA_max <- 0.1
tau_maf_min <- 0.1

dimensions2 <- c(0,0)
dimensions <- dim(g)

while(!identical(dimensions,dimensions2)){
  dimensions <- dim(g)
  
  
  # remove marker with too much NA
  non_na <- apply(g%>% dplyr::select(-chr, -pos, -dcum, -marker), 1, function(x) length(which(!is.na(x))))
  na <-  apply(g%>% dplyr::select(-chr, -pos,-dcum, -marker), 1, function(x) length(which(is.na(x))))
  missing_data_rate=na/(na+non_na)
  
  g <- g %>% slice(which(missing_data_rate < taux_NA_max))
  
  
  #minor allele frequency
  m2 <- apply(g%>% dplyr::select(-chr, -pos,-dcum, -marker), 1, function(x) length(which(x==2)))
  m0 <-  apply(g%>% dplyr::select(-chr, -pos,-dcum, -marker), 1, function(x) length(which(x==0)))
  maf <- m2/(m2+m0)
  
  g <- g %>% slice(which(maf >tau_maf_min & maf < 1- tau_maf_min ))
  
  
  
  # remove individuals with too much NA
  non_na <- apply(g%>% dplyr::select(-chr, -pos,-dcum, -marker), 2, function(x) length(which(!is.na(x))))
  na <-  apply(g%>% dplyr::select(-chr, -pos,-dcum, -marker), 2, function(x) length(which(is.na(x))))
  missing_data_rate=na/(na+non_na)
  g <- g %>% dplyr::select(-chr, -pos, -dcum, -marker) %>%
    dplyr::select(!!which(missing_data_rate < taux_NA_max)) %>%
    cbind(., g %>% dplyr::select(chr, pos, dcum, marker))%>%
    dplyr::select(chr, pos, dcum, marker, everything()) %>%
    arrange(chr, dcum, pos)
  
  
  dimensions2 <- dim(g)
  
  
}



# change alle coding for number of alternativ copy
homo0 <- apply(g%>% dplyr::select(-chr, -pos, -dcum, -marker), 1, function(x) length(which(x==0)))
homo2 <- apply(g%>% dplyr::select(-chr, -pos, -dcum, -marker), 1, function(x) length(which(x==2)))



dom <- data.frame(homo0=homo0, homo2=homo2) %>%
  rowwise() %>%
  mutate(ref=max(homo0, homo2)) %>%
  mutate(good=ifelse(ref==homo0, T, F)) %>%
  ungroup() %>%
  mutate(SNP=g$marker)

genotyping2bis <- g[which(dom$good==T),]
genotyping2ter <- g[which(dom$good==F),] %>%
  mutate_at(vars(starts_with("CFD")), funs(abs(.-2)))


g <- rbind(genotyping2bis, genotyping2ter) %>% 
  arrange(chr, dcum, pos) %>%
  dplyr::select(-chr, -pos, -dcum) %>%
  column_to_rownames("marker") %>%
  t() %>% 
  as.data.frame() %>%
  rownames_to_column("ID") %>%
  arrange(ID)


pheno <- pheno %>% filter(ID %in% g$ID)





rm(genotyping2bis, genotyping2ter, dom)

m <- m %>% filter(marker %in% !!colnames(g)) %>%
  arrange(chr, dcum, pos) %>%
  mutate(region=NA) %>%
  mutate(population="dent") %>%
  mutate(region=NA) %>%
  dplyr::select(chr,region, pos, marker, population, dcum)

# 
# 
# g  %>%
#   group_by(chr) %>%
#   mutate_at(vars(starts_with("CFD")), funs())
# 
# vecteur <- as.numeric()
# for (i in 1:nrow(g)){
#   vecteur <- c(vecteur,g[i, -1] %>% unlist() %>% as.vector() %>% diff() %>% abs() %>% sum(na.rm = T))
#   
# }

map <- m %>% dplyr::select(marker, chr, pos) %>%
  mutate(chr=as.numeric(as.factor(chr))) %>%
  unique() %>%
  arrange(chr, pos) %>%
  column_to_rownames("marker")



g2 <- g  %>%
  mutate_at(vars(starts_with("rs")), funs(str_replace_all(., pattern = c("0"), replacement= "AA")))%>%
  mutate_at(vars(starts_with("rs")), funs(str_replace_all(., pattern = c("2"), replacement= "BB")))%>%
  column_to_rownames("ID") %>%
  as.matrix()

cat("\n\n dimension before imputation\n\n")
dim(map)
dim(g2)

#m <- matrix(as.character(unlist(m)), ncol=100, byrow=T)
# m[m=="0"] <- "AA"
# m[m=="2"] <- "BB"
# m[m=="1"] <- "AB"
# 
# rownames(m) <- fread(titre_matrix)[1:10,1] %>% unlist()
# colnames(m) <- colnames(fread(titre_matrix)[1:10,2:101])
# m


m2 <- create.gpData(geno=g2, map=map, map.unit = 'bp')
# rm(m, map, genotyping_matrix_updated, markers)

genotyping_matrix_imputed <- codeGeno(m2, impute = T,
                                      impute.type = "beagle",
                                      cores=nbcores)$geno

genotyping_matrix_imputed <- genotyping_matrix_imputed %>%
  as.data.frame() %>%
  rownames_to_column(var="ID") %>%
  dplyr::select(ID, everything())


genotyping_matrix_imputed <- sort_genotyping_matrix(genotyping_matrix_imputed, m)

m <- m %>%
  filter(marker %in% !!colnames(genotyping_matrix_imputed)) %>%
  group_by(chr) %>%
  mutate(pos=1:n()) %>%
  ungroup() %>%
  as.data.frame()





cat ("\n\n OUTPUT pheno info \n\n ")
pheno <- pheno %>% dplyr::select(ID, value, type, sim, qtls, h, r, g)
head(pheno)
tail(pheno)
dim(pheno)

write.table(pheno, titre_pheno_output, col.names = T, row.names = F, dec=".", sep="\t", quote=F)




cat ("\n\n OUTPUT marker info \n\n ")
head(m)
tail(m)
dim(m)

write.table(m, titre_markers_output, col.names = T, row.names = F, dec=".", sep="\t", quote=F)

cat ("\n\n OUTPUT genotyping \n\n ")
genotyping_matrix_imputed %>% dplyr::select(1:10) %>% head()
genotyping_matrix_imputed %>% dplyr::select(1:10) %>% tail()
write.table(genotyping_matrix_imputed, titre_genotyping_output, col.names = T, row.names = F, dec=".", sep="\t", quote=F)

genotyping_matrix_imputed %>% dim()



sessionInfo()