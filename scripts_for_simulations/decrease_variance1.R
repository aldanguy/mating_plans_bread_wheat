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







titre_parents_unselected <- variables[1]
titre_parents_selected <- variables[2]
titre_output <- variables[3]


# titre_sel_rate_input <- "/work2/genphyse/dynagen/adanguy/croisements/250222/article/progeny/TBV_progeny_sTRUE_iTRUE_q300rand_hNA_gNA_punselected_n2_mWE_CONSTRAINTS_selection_rate_temp.txt"
# titre_parents_input <- "/work2/genphyse/dynagen/adanguy/croisements/250222/article/parents/TBV_last_generation_sTRUE_iTRUE_q300rand_hNA_gNA_pselected_n2_mWE_CONSTRAINTS.txt"


cat("\n\n INPUT : parents unselected \n\n ")
unsel <- fread(titre_parents_unselected)
head(unsel)
tail(unsel)
dim(unsel)




cat("\n\n INPUT : parents selected \n\n ")
sel <- fread(titre_parents_selected)
head(sel)
tail(sel)
dim(sel)

v_unsel <- var(unsel$value)

v_sel <- var(sel$value)


d <- data.frame(population_ID=unsel$population_ID[1],
                v_unsel=v_unsel,
                v_sel=v_sel,
                ratio=v_sel/v_unsel)





cat("\n\n OUPUT : loss of genetic variance \n\n")
head(d)
dim(d)
write_delim(d , titre_output, delim = "\t", na = "NA", append = F,  col_names = T, quote_escape = "none")

sessionInfo()