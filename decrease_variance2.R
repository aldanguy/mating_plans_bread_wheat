Sys.time()
cat("\n\n decrease variance\n\n")
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







titre_input <- variables[1]
titre_output <- variables[2]


# titre_sel_rate_input <- "/work2/genphyse/dynagen/adanguy/croisements/250222/article/progeny/TBV_progeny_sTRUE_iTRUE_q300rand_hNA_gNA_punselected_n2_mWE_CONSTRAINTS_selection_rate_temp.txt"
# titre_parents_input <- "/work2/genphyse/dynagen/adanguy/croisements/250222/article/parents/TBV_last_generation_sTRUE_iTRUE_q300rand_hNA_gNA_pselected_n2_mWE_CONSTRAINTS.txt"


cat("\n\n INPUT : decrease variance \n\n ")
input <- fread(titre_input)
head(input)
tail(input)
dim(input)




input2 <- input %>%
  summarise(average_decrease=round(mean(100*ratio)), sd_decrease=round(sd(100*ratio)))



cat("\n\n OUPUT : loss of genetic variance \n\n")
head(input2)
dim(input2)
write_delim(input2 , titre_output, delim = "\t", na = "NA", append = F,  col_names = T, quote_escape = "none")

sessionInfo()