Sys.time()
cat("\n\nprogeny_diversity.R\n\n")
rm(list = ls())
graphics.off()
set.seed(1)
t1 <- Sys.time()

suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(compiler))



variables <- commandArgs(trailingOnly=TRUE)
cat("\n\nVariables : \n")
print(variables)
cat("\n\n")







titre_genotypes_input <- variables[1]
titre_markers_input <- variables[2]
titre_lines_input <- variables[3]
titre_pedigree_input <- variables[4]
selection_rate_UC3 <- as.numeric(variables[5])
titre_diversity_output <- variables[6]


# titre_genotypes_input <- "/work2/genphyse/dynagen/adanguy/croisements/250222/article/progeny/temp/sTRUE_iTRUE_q300rand_hNA_gNA_punselected_n1_mWE_CONSTRAINTS_PM_12/genotypes_progeny_sTRUE_iTRUE_q300rand_hNA_gNA_punselected_n1_mWE_CONSTRAINTS_PM_12.txt"    
# titre_markers_input <- "/work2/genphyse/dynagen/adanguy/croisements/250222/article/markers/markers_QTLs_sTRUE_iTRUE_q300rand_hNA_gNA_punselected_n1_mWE_CONSTRAINTS.txt"                                                                                      
# titre_lines_input <- "/work2/genphyse/dynagen/adanguy/croisements/250222/article/progeny/TBV_progeny_sTRUE_iTRUE_q300rand_hNA_gNA_punselected_n1_mWE_CONSTRAINTS_PM_12.txt"                                                                                 
# titre_pedigree_input <-  "/work2/genphyse/dynagen/adanguy/croisements/250222/article/progeny/temp/sTRUE_iTRUE_q300rand_hNA_gNA_punselected_n1_mWE_CONSTRAINTS_PM_12/pedigree_progeny_temp_sTRUE_iTRUE_q300rand_hNA_gNA_punselected_n1_mWE_CONSTRAINTS_PM_12.txt"
# selection_rate_UC3 <- 0.07                                                                                                                                                                                                                                
# titre_diversity_output <- "/work2/genphyse/dynagen/adanguy/croisements/250222/article/progeny/TBV_progeny_sTRUE_iTRUE_q300rand_hNA_gNA_punselected_n1_mWE_CONSTRAINTS_PM_12_diversity.txt"                                                                       



cat("\n\n INPUT : geno info \n\n ")
g <- fread(titre_genotypes_input)
g%>%dplyr::select(1:10) %>% head()
g%>%dplyr::select(1:10) %>% tail()
dim(g)


cat("\n\n INPUT : markers info \n\n ")
m <- fread(titre_markers_input)
head(m)
tail(m)
dim(m)

cat("\n\n INPUT : lines info \n\n ")
l <- fread(titre_lines_input)
head(l)
tail(l)
dim(l)

cat("\n\n INPUT : pedigree info \n\n ")
ped <- fread(titre_pedigree_input)
head(ped)
tail(ped)
dim(ped)

l_truncation <- l %>%
  mutate(q=quantile(value, 1-selection_rate_UC3)) %>%
  filter(value >=q) %>%
  dplyr::select(ID) %>%
  unlist() %>%
  as.vector()


m2 <- m %>% arrange(chr, dcum, marker) %>% 
  filter(value != 0) %>% 
  dplyr::select(marker, value) 

qtls <- m2 %>% dplyr::select(marker) %>% unlist() %>% as.vector()
values <- m2 %>% dplyr::select(value) %>% unlist() %>% as.vector()
g2 <- g%>% 
  filter(ID %in% !!l_truncation) %>%
  dplyr::select(one_of(qtls))




maf_truncation <- as.vector(apply(g2,
                                  2, function(x) 2*length(which(x==2)) + length(which(x==1)))/(2*nrow(g2)))

genic_diversity_truncation <- sum(4*maf_truncation*(1-maf_truncation)*(m2$value)^2)


nparents_truncation <- ped %>% filter(ID %in% !!l_truncation) %>%
  dplyr::select(P1, P2) %>%
  unlist() %>%
  as.vector() %>%
  unique() %>%
  length()


out <- data.frame(selected_progeny="truncation", genic_div=genic_diversity_truncation, nparents=nparents_truncation) %>%
  mutate(ID=l$ID[1]) %>%
  inner_join(l %>% dplyr::select(-one_of("value", "info")), by="ID") %>%
  dplyr::select(-ID) %>%
  dplyr::select(selected_progeny, genic_div, everything()) 



cat("\n\n OUPUT : diversity \n\n")
head(out)
tail(out)
dim(out)
write_delim(out, titre_diversity_output, delim = "\t", na = "NA", append = F,  col_names = T, quote_escape = "none")


sessionInfo()