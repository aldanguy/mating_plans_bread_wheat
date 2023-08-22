

# Goal : extract outputs from lp_solve

Sys.time()
cat("\n\n13_after_ple.R\n\n")
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

titre_mating_plan_lpsolve_input <- variables[1]
titre_criteria_input <- variables[2]
model_name <- variables[3]
titre_mating_plan_output <- variables[4]




cat("\n\n INPUT crosses info \n\n")
c <- fread(titre_criteria_input)
head(c)
tail(c)
dim(c)


cat("\n\n INPUT best crosses info \n\n")
m <- fread(titre_mating_plan_lpsolve_input, skip=4)
head(m)
tail(m)
dim(m)


mf <- m  %>% rename(nbprogeny=V2) %>%
  filter(grepl("x",V1)) %>%
  cbind(., c %>% dplyr::select(P1, P2)) %>%
  filter(nbprogeny>0) %>% 
  mutate(optimization=!!model_name)%>%
  arrange(P1, P2) %>%
  mutate(P1=gsub("_XXX.*","", P1)) %>%
  mutate(P2=gsub("_XXX.*","", P2)) %>%
  dplyr::select(P1, P2, nbprogeny)



cat("\n\nOUTPUT : mating plan \n\n")
head(mf)
tail(mf)
dim(mf)
write_delim(mf, titre_mating_plan_output, col_names = T, delim="\t", append = F, na="NA", quote_escape="none")




sessionInfo()
