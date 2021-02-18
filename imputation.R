


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



titre_genotyping_matrix_updated <- variables[1]
titre_markers <- variables[2]
titre_genotyping_matrix_imputed <- variables[3]
nbcores <- as.numeric(variables[4])
titre_function_sort_genotyping_matrix <- variables[5]

# titre_genotyping_matrix_updated <-  "/work/adanguy/these/croisements/090221/genotyping_matrix_filtered.txt"       
# titre_markers <- "/work/adanguy/these/croisements/amont/markers_filtered.txt"                  
# # titre_genotyping_matrix_imputed <-  "/work/adanguy/these/croisements/amont/genotyping_matrix_filtered_imputed.txt"
# # nbcores <- 1
# titre_function_sort_genotyping_matrix <- "/work/adanguy/these/croisements/scripts/sort_genotyping_matrix.R"

source(titre_function_sort_genotyping_matrix)


cat("\n\n INPUT : gentyping matrix updated \n\n")
genotyping_matrix_updated <- fread(titre_genotyping_matrix_updated)
genotyping_matrix_updated[1:10,1:10]
dim(genotyping_matrix_updated)
# column 1 = line 2 = modified ID for variety (string, as many levels as number of lines, i.e. 2089)
# column 2 - 19751 = genotype at each SNP
# dimension: 2089 * 19821



cat("\n\n INPUT : markers with physical position \n\n")
markers <- fread(titre_markers) %>% arrange(chr, pos)
head(markers)
dim(markers)
# column 1 = chr = chr ID with letters (string, 21 levels)
# column 2 = region = ID of chr region (string, 5 levels R1, R2a, C, R2b, R3)
# column 4 = pos = physical position of marker (intergers, units bp)
# column 5 = marker = marker ID (string, as many levels as number of markers, here 31 314)
# dimension: 31314*4


genotyping_matrix_updated <- sort_genotyping_matrix(genotyping_matrix_updated, markers)

map <- markers %>% dplyr::select(marker, chr, pos) %>%
  arrange(chr, pos) %>%
  column_to_rownames("marker")

# markers <- sort(sample(1:ncol(genotyping_matrix_updated), size=20, replace = F))
# map <- map[markers,]
# genotyping_matrix_updated <- fread(titre_genotyping_matrix_updated)
# genotyping_matrix_updated <- as.data.frame(genotyping_matrix_updated)[1:15, c(1,markers+1)]


m <- genotyping_matrix_updated  %>%
  mutate_at(vars(starts_with("AX")), funs(str_replace_all(., pattern = c("0"), replacement= "AA")))%>%
  mutate_at(vars(starts_with("AX")), funs(str_replace_all(., pattern = c("2"), replacement= "BB")))%>%
  mutate_at(vars(starts_with("AX")), funs(str_replace_all(., pattern = c("1"), replacement= "AB"))) %>%
  column_to_rownames("line2") %>%
  as.matrix()



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
  rownames_to_column(var="line2") %>%
  dplyr::select(line2, everything())


genotyping_matrix_imputed <- sort_genotyping_matrix(genotyping_matrix_imputed, markers)





cat("\n\n OUTPUT : gentyping matrix imputed \n\n")
genotyping_matrix_imputed[1:10,1:10]
dim(genotyping_matrix_imputed)
# column 1 = line 2 = modified ID for variety (string, as many levels as number of lines, i.e. 2089)
# column 2 - 19751 = genotype at each SNP
# dimension: 2089 * 19821
write_delim(genotyping_matrix_imputed, titre_genotyping_matrix_imputed, col_names = T, quote_escape="none", delim="\t", na="NA", append=F)


sessionInfo()



