

Sys.time()
cat("\n\average_ratio_accuracy\n\n")
rm(list = ls())
graphics.off()
set.seed(1)
t1 <-Sys.time() 

suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(compiler))



variables <- commandArgs(trailingOnly=TRUE)
cat("\n\nVariables : \n")
print(variables)
cat("\n\n")



titre_ratio <- variables[1]
titre_accuracy <-  variables[2]
titre_bias_output <- variables[3]
titre_ratio_output<- variables[4]
titre_correlations_input <- variables[5]
titre_correlations_output <- variables[6]

cat("\n\n INPUT : ratio \n\n ")
ratio <- fread(titre_ratio)
head(ratio)
tail(ratio)
dim(ratio)

cat("\n\n INPUT : accuracy \n\n ")
accuracy <- fread(titre_accuracy)
head(accuracy)
tail(accuracy)
dim(accuracy)

cat("\n\n INPUT : correlations \n\n ")
correlations <- fread(titre_correlations_input)
head(correlations)
tail(correlations)
dim(correlations)



ratio_f <- ratio %>% 
  group_by(population, qtls_info, info) %>%
  summarise(value=mean(ratio), 
            sd=sd(ratio))%>%
  mutate(metric="ratio") %>%
  as.data.frame()


var_sd_f <- ratio %>% 
  group_by(population, qtls_info, info) %>%
  summarise(value=mean(var_sd), 
            sd=sd(var_sd))%>%
  mutate(metric="var_sd")%>%
  as.data.frame()


var_PM_f <- ratio %>% 
  group_by(population, qtls_info, info) %>%
  summarise(value=mean(var_PM), 
            sd=sd(var_PM)) %>%
  mutate(metric="var_PM")%>%
  as.data.frame()



final1 <- rbind(ratio_f, var_PM_f, var_sd_f) %>%
  dplyr::select(-info)


ratio_var_sd_esti_f <- accuracy %>% 
  group_by(population, info) %>%
  summarise(value=mean(ratio_var_sd_esti), 
            sd=sd(ratio_var_sd_esti))%>%
  mutate(metric="ratio_var_sd_esti")%>%
  as.data.frame()

cor_sd_f <- accuracy %>% 
  group_by(population, info) %>%
  summarise(value=mean(cor_sd), 
            sd=sd(cor_sd))%>%
  mutate(metric="cor_sd")%>%
  as.data.frame()

ratio_var_PM_esti_f <- accuracy %>% 
  group_by(population, info) %>%
  summarise(value=mean(ratio_var_PM_esti), 
            sd=sd(ratio_var_PM_esti))%>%
  mutate(metric="ratio_var_PM_esti")%>%
  as.data.frame()

cor_PM_f <- accuracy %>% 
  group_by(population, info) %>%
  summarise(value=mean(cor_PM), 
            sd=sd(cor_PM))%>%
  mutate(metric="cor_PM")%>%
  as.data.frame()






final2 <- rbind(ratio_var_sd_esti_f, ratio_var_PM_esti_f, cor_sd_f, cor_PM_f) %>%
  mutate(training=case_when(info=="population_predict_population" & population=="unselected" ~ "unselected",
                          info=="population_predict_population" & population=="selected" ~ "selected",
                          info=="cross_validation" & population=="unselected" ~ "selected",
                          info=="cross_validation" & population=="selected" ~ "unselected")) %>%
  mutate(validation=case_when(info=="population_predict_population" & population=="unselected" ~ "unselected",
                          info=="population_predict_population" & population=="selected" ~ "selected",
                          info=="cross_validation" & population=="unselected" ~ "unselected",
                          info=="cross_validation" & population=="selected" ~ "selected")) %>%
  dplyr::select(-info, -population)


correlations2 <- correlations %>%
  group_by(population, qtls_info, criterion1, criterion2) %>%
  summarise(value=mean(correlation), 
            sd=sd(correlation)) %>%
  mutate(metric="correlation")%>%
  as.data.frame()

cat("\n\nOUTPUT : ratio \n\n")
head(final1)
dim(final1)
write_delim(final1, titre_ratio_output, col_names = T, delim="\t", append = F, na="NA", quote_escape="none")

cat("\n\nOUTPUT : bias \n\n")
head(final2)
dim(final2)
write_delim(final2, titre_bias_output, col_names = T, delim="\t", append = F, na="NA", quote_escape="none")


cat("\n\nOUTPUT : correlations \n\n")
head(correlations2)
tail(correlations2)
dim(correlations2)
write_delim(correlations2, titre_correlations_output, col_names = T, delim="\t", append = F, na="NA", quote_escape="none")


sessionInfo()
