Sys.time()
cat("\n\nprogeny_gain.R\n\n")
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







titre_lines_input <- variables[1]
selection_rate_UC3 <- as.numeric(variables[2])
titre_gain_output <- variables[3]
titre_selection_rate_output <- variables[4]


# 
#  titre_lines_input <- "/work2/genphyse/dynagen/adanguy/croisements/250222/article/progeny/TBV_progeny_sTRUE_iTRUE_q300rand_hNA_gNA_punselected_n1_mWE_CONSTRAINTS__sTRUE_iTRUE_q300rand_hNA_gNA_punselected_n1_mWE_CONSTRAINTS_EMBV_1.txt"     
#  selection_rate_UC3 <- 0.07                                                                                                                                                                                                                 
#  titre_gain_output <-  "/work2/genphyse/dynagen/adanguy/croisements/250222/article/progeny/TBV_progeny_sTRUE_iTRUE_q300rand_hNA_gNA_punselected_n1_mWE_CONSTRAINTS__sTRUE_iTRUE_q300rand_hNA_gNA_punselected_n1_mWE_CONSTRAINTS_EMBV_1_gain.txt"
#  




cat("\n\n INPUT : markers info \n\n ")
progeny <- fread(titre_lines_input)
head(progeny)
tail(progeny)
dim(progeny)


best_progeny <- max(progeny$value)

breeding_progeny <- progeny %>%
  dplyr::select(ID, value) %>%
  mutate(q=quantile(value, 1-selection_rate_UC3)) %>%
  filter(value>=q) %>%
  dplyr::select(value) %>%
  unlist() %>%
  as.vector() %>%
  mean()

gain <- data.frame(selected_progeny=c("best","truncation"), value=c(best_progeny, breeding_progeny)) %>%
  mutate(ID=!!progeny$ID[1]) %>%
  inner_join(progeny %>% dplyr::select(-one_of("value")), by="ID") %>%
  dplyr::select(-ID) %>%
  dplyr::select(selected_progeny, value, info, everything())

progeny <- progeny %>%
  arrange(desc(value))
selecton_rate_final <- data.frame()

for (i in 1:nrow(progeny)){

selection_rate <- i/nrow(progeny)

gain_at_selection_rate <- progeny %>%
  slice(1:i) %>%
  dplyr::select(value) %>%
  unlist() %>%
  as.vector()%>%
  mean()


selecton_rate_temp <- data.frame(selection_rate=selection_rate, value=gain_at_selection_rate)
selecton_rate_final <- rbind(selecton_rate_final, selecton_rate_temp)

}

selecton_rate_final <- selecton_rate_final %>%
  mutate(ID=!!progeny$ID[1]) %>%
  inner_join(progeny %>% dplyr::select(-one_of("value")), by="ID") %>%
  dplyr::select(-ID) %>%
  dplyr::select(selection_rate, value, info, everything())


cat("\n\n OUPUT : gain \n\n")
head(gain)
dim(gain)
write_delim(gain, titre_gain_output, delim = "\t", na = "NA", append = F,  col_names = T, quote_escape = "none")


cat("\n\n OUPUT : selection_rate \n\n")
head(selecton_rate_final)
dim(selecton_rate_final)
write_delim(selecton_rate_final, titre_selection_rate_output, delim = "\t", na = "NA", append = F,  col_names = T, quote_escape = "none")


sessionInfo()