Sys.time()
cat("\n\analyse_gain.r\n\n")
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







titre_sel_rate_input <- variables[1]
titre_gain_input <- variables[2]
titre_diversity_input <- variables[3]
titre_selection_rate_output <- variables[4]
titre_diversity_output<- variables[5]
titre_gain_output<- variables[6]



# titre_sel_rate_input <- "/work2/genphyse/dynagen/adanguy/croisements/250222/article/progeny/TBV_progeny_sTRUE_iTRUE_q300rand_hNA_gNA_punselected_n2_mWE_CONSTRAINTS_selection_rate_temp.txt"
# titre_parents_input <- "/work2/genphyse/dynagen/adanguy/croisements/250222/article/parents/TBV_last_generation_sTRUE_iTRUE_q300rand_hNA_gNA_pselected_n2_mWE_CONSTRAINTS.txt"


cat("\n\n INPUT : sel rate \n\n ")
sel <- fread(titre_sel_rate_input)
head(sel)
tail(sel)
dim(sel)



cat("\n\n INPUT : gain \n\n ")
gain <- fread(titre_gain_input)
head(gain)
tail(gain)
dim(gain)


cat("\n\n INPUT : diversity \n\n ")
diversity <- fread(titre_diversity_input)
head(diversity)
tail(diversity)
dim(diversity)


sel1 <- sel %>%
  group_by(population, criterion, qtls_info, CONSTRAINTS, selection_rate, population_ID) %>%
  summarise(value=mean(value))%>%
  as.data.frame()
  

gain1 <- gain %>%
  group_by(population, criterion, qtls_info, CONSTRAINTS, selected_progeny, population_ID) %>%
  summarise(value=mean(value))%>%
  as.data.frame()


diversity1 <- diversity %>%
  group_by(population, criterion, qtls_info, CONSTRAINTS, selected_progeny, population_ID) %>%
  summarise(genic_div=mean(genic_div), nparents=mean(nparents))%>%
  as.data.frame()

cat("\n\n OUPUT : selection_rate \n\n")
head(sel1)
tail(sel1)
dim(sel1)
write_delim(sel1, titre_selection_rate_output, delim = "\t", na = "NA", append = F,  col_names = T, quote_escape = "none")


cat("\n\n OUPUT : gain \n\n")
head(gain1)
tail(gain1)
dim(gain1)
write_delim(gain1, titre_gain_output, delim = "\t", na = "NA", append = F,  col_names = T, quote_escape = "none")


cat("\n\n OUPUT : diversity \n\n")
head(diversity1)
tail(diversity1)
dim(diversity1)
write_delim(diversity1, titre_diversity_output, delim = "\t", na = "NA", append = F,  col_names = T, quote_escape = "none")

sessionInfo()