Sys.time()
cat("\n\analyse_similarity.R\n\n")
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







titre_similarity_input <- variables[1]
titre_similarity_output <- variables[2]

# titre_similarity_input <-  "/work2/genphyse/dynagen/adanguy/croisements/250222/article/similarity_mating_plans/similarity.txt"
# titre_similarity_output <-  "/work/adanguy/these/croisements/250222/results/similarity.txt"                                    
# 


cat("\n\n INPUT : similarity \n\n ")
s <- fread(titre_similarity_input)
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
  inner_join(order_criterion, by=c("criterion1"="criterion"))%>%
  inner_join(order_criterion, by=c("criterion2"="criterion")) %>%
  rename(ordre1=ordre.x)%>%
  rename(ordre2=ordre.y) %>%
  mutate(criterionA=ifelse(ordre1 <= ordre2, as.character(criterion1), as.character(criterion2))) %>%
  mutate(criterionB=ifelse(ordre1 > ordre2, as.character(criterion1), as.character(criterion2))) %>%
  dplyr::select(-criterion1, -criterion2, -ordre1, -ordre2) %>%
  rename(criterion1=criterionA, criterion2=criterionB) %>%
  unique() %>%
  group_by(population, CONSTRAINTS, qtls_info, population_ID, metric) %>%
  mutate(similarity_PM=ifelse(criterion1=="PM" & criterion2=="PM" & metric=="similarity", value, NA)) %>%
  mutate(similarity_PM=max(similarity_PM, na.rm = T)) %>%
  mutate(value=ifelse(criterion1==criterion2 & metric=="similarity", 100*value/similarity_PM, 100*value)) %>%
  group_by(population, CONSTRAINTS, qtls_info, criterion1, criterion2, metric) %>%
  summarise(sd=sd(value), value=mean(value)) %>%
  as.data.frame()

cat("\n\n OUPUT : similarity \n\n")
head(s2)
tail(s2)
dim(s2)
write_delim(s2, titre_similarity_output, delim = "\t", na = "NA", append = F,  col_names = T, quote_escape = "none")


sessionInfo()