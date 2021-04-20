


# Goal : impute missing data in genotypes 
# Input : genotyping matrix and positions of markers
# Output : imputated genotyping matrix



Sys.time()
cat("\n\nimputation.R\n\n")
rm(list = ls())
graphics.off()
set.seed(1)

suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(compiler))
suppressPackageStartupMessages(library(synbreed))
suppressPackageStartupMessages(library(parallel))
suppressPackageStartupMessages(library(readr))


variables <- commandArgs(trailingOnly=TRUE)
cat("\n\nVariables : \n")
print(variables)
cat("\n\n")



titre_genotyping_input <- variables[1]
titre_markers_input <- variables[2]
nbcores <- as.numeric(variables[3])
titre_function_sort_genotyping_matrix <- variables[4]
titre_genotyping_output <- variables[5]
titre_markers_output <- variables[6]

# titre_genotyping_input <- "/work2/genphyse/dynagen/adanguy/croisements/050321/prepare/genotyping_1.txt"
# titre_markers_input <- "/work2/genphyse/dynagen/adanguy/croisements/050321/prepare/markers_2.txt"   
# nbcores <- 1                                                                       
# titre_function_sort_genotyping_matrix <- "/work/adanguy/these/croisements/scripts/sort_genotyping_matrix.R"           
# titre_genotyping_output <- "/work2/genphyse/dynagen/adanguy/croisements/050321/prepare/genotyping.txt"  
# titre_markers_output <- "/work2/genphyse/dynagen/adanguy/croisements/050321/prepare/markers.txt" 
# 



source(titre_function_sort_genotyping_matrix)


cat("\n\n INPUT : genotyping \n\n")
fread(titre_genotyping_input) %>% select(1:10) %>% slice(1:10)
fread(titre_genotyping_input) %>% select(1:10) %>% slice((nrow(.)-10):nrow(.))
fread(titre_genotyping_input) %>% dim()


cat("\n\n INPUT : markers info \n\n")
fread(titre_markers_input) %>% head()
fread(titre_markers_input) %>% tail()
fread(titre_markers_input) %>% dim()


markers2 <- fread(titre_markers_input) %>%
  filter(marker %in% colnames(fread(titre_genotyping_input))) %>%
  arrange(chr, pos, marker, population)


genotyping_matrix_updated <- sort_genotyping_matrix(fread(titre_genotyping_input), markers2)

map <- markers2 %>% dplyr::select(marker, chr, pos) %>%
  filter(marker %in% colnames(genotyping_matrix_updated)) %>%
  mutate(chr=as.numeric(as.factor(chr))) %>%
  unique() %>%
  arrange(chr, pos) %>%
  column_to_rownames("marker")


# to_keep <- sort(sample(1:nrow(map), size=1500, replace=F))
# to_keep_m <- c(1, to_keep +1)
# genotyping_matrix_updated <- genotyping_matrix_updated[1:200, to_keep_m]
# map <- map[to_keep, ]

# markers <- sort(sample(1:ncol(genotyping_matrix_updated), size=20, replace = F))
# map <- map[markers,]
# genotyping_matrix_updated <- fread(titre_genotyping_matrix_updated)
# genotyping_matrix_updated <- as.data.frame(genotyping_matrix_updated)[1:15, c(1,markers+1)]


m <- genotyping_matrix_updated  %>%
  mutate_at(vars(starts_with("AX")), funs(str_replace_all(., pattern = c("0"), replacement= "AA")))%>%
  mutate_at(vars(starts_with("AX")), funs(str_replace_all(., pattern = c("2"), replacement= "BB")))%>%
  mutate_at(vars(starts_with("AX")), funs(str_replace_all(., pattern = c("1"), replacement= "AB"))) %>%
  column_to_rownames("ID") %>%
  as.matrix()

cat("\n\n dimension before imputation\n\n")
dim(m)
dim(map)

#m <- matrix(as.character(unlist(m)), ncol=100, byrow=T)
# m[m=="0"] <- "AA"
# m[m=="2"] <- "BB"
# m[m=="1"] <- "AB"
# 
# rownames(m) <- fread(titre_matrix)[1:10,1] %>% unlist()
# colnames(m) <- colnames(fread(titre_matrix)[1:10,2:101])
# m


m2 <- create.gpData(geno=m, map=map, map.unit = 'bp')
# rm(m, map, genotyping_matrix_updated, markers)

genotyping_matrix_imputed <- codeGeno(m2, impute = T,
                                      impute.type = "beagle",
                                      cores=nbcores )$geno

genotyping_matrix_imputed <- genotyping_matrix_imputed %>% as.data.frame() %>%
  rownames_to_column(var="ID") %>%
  dplyr::select(ID, everything())


genotyping_matrix_imputed <- sort_genotyping_matrix(genotyping_matrix_imputed, markers2)





cat("\n\n OUTPUT : gentyping matrix imputed \n\n")
genotyping_matrix_imputed %>% select(1:10) %>% slice(1:10)
genotyping_matrix_imputed %>% select(1:10) %>% slice((nrow(.)-10):nrow(.))
genotyping_matrix_imputed %>% dim()
write_delim(genotyping_matrix_imputed, titre_genotyping_output, col_names = T, quote_escape="none", delim="\t", na="NA", append=F)


cat("\n\n OUTPUT : markers info \n\n")
head(markers2)
tail(markers2)
dim(markers2)
write_delim(markers2, titre_markers_output, col_names = T, quote_escape="none", delim="\t", na="NA", append=F)


sessionInfo()



