Sys.time()
cat("\n\analyse_gain2.R\n\n")
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




# titre_sel_rate_input <- "/work2/genphyse/dynagen/adanguy/croisements/250222/article/progeny/selection_rate_temp5.txt"
# titre_gain_input <-  "/work2/genphyse/dynagen/adanguy/croisements/250222/article/progeny/gain_temp5.txt"          
# titre_diversity_input <-  "/work2/genphyse/dynagen/adanguy/croisements/250222/article/progeny/diversity_temp5.txt"     
# 



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
  group_by(population, qtls_info, CONSTRAINTS, selection_rate, criterion) %>%
  summarise(sd=round(sd(100*value),2), value=round(mean(100*value),2))%>%
  as.data.frame()

gain1 <- gain %>%
  group_by(population, qtls_info, CONSTRAINTS, selected_progeny, criterion, metric) %>%
  summarise(sd=round(sd(100*value),2), value=round(mean(100*value),2))%>%
  as.data.frame()



diversity1 <- diversity %>%
  group_by(population, qtls_info, CONSTRAINTS, selected_progeny, criterion) %>%
  summarise(sd=round(sd(nparents),2), value=round(mean(nparents),2)) %>%
  mutate(info="nparents")%>%
  as.data.frame()



diversity2 <- diversity %>%
  group_by(population, qtls_info, CONSTRAINTS, selected_progeny, criterion) %>%
  summarise(sd=round(sd(100*genic_div),2), value=round(mean(100*genic_div),2))%>%
  mutate(info="genic_div") %>%
  as.data.frame()


diversity <- rbind(diversity1, diversity2) %>%
  arrange(population, qtls_info, CONSTRAINTS, selected_progeny, criterion, info)



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
head(diversity)
tail(diversity)
dim(diversity)
write_delim(diversity, titre_diversity_output, delim = "\t", na = "NA", append = F,  col_names = T, quote_escape = "none")

sessionInfo()