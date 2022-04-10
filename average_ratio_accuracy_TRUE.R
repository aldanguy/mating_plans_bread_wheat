

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



titre_accuracy <-  variables[1]
titre_bias_output <- variables[2]


cat("\n\n INPUT : accuracy \n\n ")
accuracy <- fread(titre_accuracy)
head(accuracy)
tail(accuracy)
dim(accuracy)




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

bias_sd2_f <- accuracy %>% 
  group_by(population, info) %>%
  summarise(value=mean(bias_sd2), 
            sd=sd(bias_sd2))%>%
  mutate(metric="bias_sd2")%>%
  as.data.frame()





final2 <- rbind(ratio_var_sd_esti_f, ratio_var_PM_esti_f, cor_sd_f, cor_PM_f, bias_sd2_f) %>%
  mutate(training=case_when(info=="population_predict_population" & population=="unselected" ~ "unselected",
                          info=="population_predict_population" & population=="selected" ~ "selected",
                          info=="cross_validation" & population=="unselected" ~ "selected",
                          info=="cross_validation" & population=="selected" ~ "unselected")) %>%
  mutate(validation=case_when(info=="population_predict_population" & population=="unselected" ~ "unselected",
                          info=="population_predict_population" & population=="selected" ~ "selected",
                          info=="cross_validation" & population=="unselected" ~ "unselected",
                          info=="cross_validation" & population=="selected" ~ "selected")) %>%
  dplyr::select(-info, -population)



cat("\n\nOUTPUT : bias \n\n")
head(final2)
dim(final2)
write_delim(final2, titre_bias_output, col_names = T, delim="\t", append = F, na="NA", quote_escape="none")



sessionInfo()
