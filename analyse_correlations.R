Sys.time()
cat("\n\analyse_correlations.R\n\n")
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







titre_correlations_input <- variables[1]
titre_correlations_output <- variables[2]

# titre_similarity_input <-  "/work2/genphyse/dynagen/adanguy/croisements/250222/article/similarity_mating_plans/similarity.txt"
# titre_similarity_output <-  "/work/adanguy/these/croisements/250222/results/similarity.txt"                                    
# 


cat("\n\n INPUT : correlations \n\n ")
s <- fread(titre_correlations_input)
head(s)
tail(s)
dim(s)

criteria <- s %>% dplyr::select(criterion1, criterion2) %>%
  unlist() %>%
  as.vector() %>%
  unique() %>%
  sort()

order_criterion <- data.frame(criterion=criteria, ordre=1:length(criteria))


s2 <- s %>%
 group_by(population, CONSTRAINTS, qtls_info, criterion1, criterion2) %>%
  summarise(sd=round(sd(100*value)), value=round(mean(100*value))) %>%
  as.data.frame()

cat("\n\n OUPUT : correlations \n\n")
head(s2)
tail(s2)
dim(s2)
write_delim(s2, titre_correlations_output, delim = "\t", na = "NA", append = F,  col_names = T, quote_escape = "none")


sessionInfo()