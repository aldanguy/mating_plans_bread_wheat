


Sys.time()
cat("\n\nconvert_LDAK_matrix.R\n\n")
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



titre_g <- variables[1]
titre_output <- variables[2]
titre_lines <- variables[3]


# titre_l <- "/work2/genphyse/dynagen/adanguy/croisements/190821/ibs/for_ldak/simTRUE_300rand_r1_unselected/LDAK-Thin.grm.raw"   
# titre_output <-  "/work2/genphyse/dynagen/adanguy/croisements/190821/ibs/ibs/ibs_ldak_simTRUE_300rand_r1_unselected.txt"             
# titre_lines <- "/work2/genphyse/dynagen/adanguy/croisements/190821/value_crosses/lines/lines_tbv_unselected_simTRUE_300rand_r1.txt"
# titre_recruited_parents <- "/work2/genphyse/dynagen/adanguy/croisements/190821/ibs/ibs/recruited_parents_simTRUE_300rand_r1_unselected.txt"


cat("\n\n INPUT G matrix from ldak \n\n")
l <- fread(titre_g) %>% as.data.frame()
l %>% dplyr::select(1:10) %>% head()
l %>% dplyr::select(1:10) %>% tail()
dim(l)



cat("\n\n INPUT lines names \n\n")
lines <- fread(titre_lines)
head(lines)
tail(lines)
dim(lines)



lines2 <- lines %>% arrange(ID) %>% mutate(index=1:n()) %>% dplyr::select(ID, index)


index1 <- as.numeric()
index2 <- as.numeric()
for (i in 1:nrow(l)){
  
  
  index1 <- c(index1, rep(1:i))
  index2 <- c(index2, rep(i, times=i))
  
  
}


l2<- data.frame(index1=index1, index2=index2, value=l[upper.tri(l, diag=T)])


l2 <- l2 %>%
  inner_join(lines2, by=c("index1"="index")) %>%
  rename(ID1=ID) %>%
  inner_join(lines2, by=c("index2"="index")) %>%
  rename(ID2=ID) %>%
  mutate(P1=ifelse(index1 <= index2, ID1, ID2))%>%
  mutate(P2=ifelse(index1 >= index2, ID1, ID2)) %>%
  dplyr::select(P1, P2, value) %>%
  mutate(ID=lines$ID[1]) %>%
  inner_join(lines %>% dplyr::select(-one_of("value", "info")), by="ID") %>%
  mutate(info="IBS_LDAK") %>%
  arrange(P1, P2) %>%
  dplyr::select(P1, P2, value, info, one_of("simulation", "qtls", "qtls_info", "heritability", "genomic", "population", "population_ID" ))






cat("\n\n OUPUT IBS \n\n")

head(l2)
tail(l2)
dim(l2)

write.table(l2, titre_output, col.names = T, dec=".", sep=" ", quote=F, row.names = F)

sessionInfo()
