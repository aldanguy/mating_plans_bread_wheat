Sys.time()
cat("\n\nanalyse_gain3.R\n\n")
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
titre_impact_constraints_output <- variables[7]




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
  filter(metric=="RI") %>%
  group_by(population, qtls_info, CONSTRAINTS, selected_progeny, criterion, metric) %>%
  summarise(sd=round(sd(100*value),2), value=round(mean(100*value),2))%>%
  as.data.frame()



datatest <- gain %>%
  filter(metric=="RI") %>%
  mutate(criterion=factor(criterion, levels=c("PM", "UC1","UC2","UC3", "EMBV", "OHV", "PROBA"))) 
  
for (population in c("selected","unselected")){
  
  for (qtls_info in c("TRUE", "FALSE")){
    
    for (CONSTRAINTS in c("CONSTRAINTS", "NO_CONSTRAINTS")){
      
      
      print(paste(population, qtls_info, CONSTRAINTS))
      
    
    
    datatest <- gain %>%
      filter(metric=="RI") %>%
      filter(selected_progeny=="best") %>%
      
      mutate(criterion=factor(criterion, levels=c("PM", "UC1","UC2","UC3", "EMBV", "OHV"))) %>%
      filter(population==!!population & qtls_info==!!qtls_info & CONSTRAINTS==!!CONSTRAINTS) %>%
      dplyr::select(value, criterion)
    
    
    print(summary(lm(value~criterion, datatest)))
    
    print(pairwise.t.test(datatest$value, datatest$criterion, p.adjust.method = "bonf"))
    
    
    
  }
}
}
  
  
gain2 <- gain %>%
  filter(metric=="sd") %>%
  group_by(population, qtls_info, CONSTRAINTS, selected_progeny, criterion, metric) %>%
  summarise(sd=round(sd(value),2), value=round(mean(value),2))%>%
  as.data.frame()



gain3 <- gain %>%
  filter(metric=="sd_raw") %>%
  group_by(population, qtls_info, CONSTRAINTS, selected_progeny, criterion, metric) %>%
  summarise(sd=round(sd(value),2), value=round(mean(value),2))%>%
  as.data.frame()

gain1 <- rbind(gain1, gain2, gain3)


gain_CONSTRAINTS_NOCONSTRAINTS_best <- gain %>%
  filter(metric=="sd_raw") %>%
  filter(selected_progeny=="best") %>%
  group_by(population, qtls_info, population_ID, CONSTRAINTS) %>%
  summarise(value=mean(value, na.rm=T)) %>%
  pivot_wider(id_cols = c("population", "qtls_info", "population_ID"), names_from="CONSTRAINTS", values_from = "value") %>%
  mutate(ratio=CONSTRAINTS/NO_CONSTRAINTS) %>%
  group_by(population, qtls_info) %>%
  summarise(sd=round(sd(ratio, na.rm=T),2), value=round(mean(ratio, na.rm=T),2)) %>%
  mutate(metric="gain_best") %>%
  as.data.frame()
  

gain_CONSTRAINTS_NOCONSTRAINTS_truncation <- gain %>%
  filter(metric=="sd_raw") %>%
  filter(selected_progeny=="truncation") %>%
  group_by(population, qtls_info, population_ID, CONSTRAINTS) %>%
  summarise(value=mean(value, na.rm=T)) %>%
  pivot_wider(id_cols = c("population", "qtls_info", "population_ID"), names_from="CONSTRAINTS", values_from = "value") %>%
  mutate(ratio=CONSTRAINTS/NO_CONSTRAINTS) %>%
  group_by(population, qtls_info) %>%
  summarise(sd=round(sd(ratio, na.rm=T),2), value=round(mean(ratio, na.rm=T),2)) %>%
  mutate(metric="gain_truncation") %>%
  as.data.frame()


diversity_CONSTRAINTS_NOCONSTRAINTS_truncation  <- diversity %>%
  filter(selected_progeny=="truncation") %>%
  group_by(population, qtls_info, population_ID, CONSTRAINTS) %>%
  summarise(value=mean(genic_div_raw)) %>%
  pivot_wider(id_cols = c("population", "qtls_info", "population_ID"), names_from="CONSTRAINTS", values_from = "value") %>%
  mutate(ratio=CONSTRAINTS/NO_CONSTRAINTS) %>%
  group_by(population, qtls_info) %>%
  summarise(sd=round(sd(ratio, na.rm=T),2), value=round(mean(ratio, na.rm=T),2)) %>%
  mutate(metric="div_truncation") %>%
  as.data.frame()

impact_constraints <- rbind(gain_CONSTRAINTS_NOCONSTRAINTS_best, gain_CONSTRAINTS_NOCONSTRAINTS_truncation, diversity_CONSTRAINTS_NOCONSTRAINTS_truncation)

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


diversity3 <- diversity %>%
  group_by(population, qtls_info, CONSTRAINTS, selected_progeny, criterion) %>%
  summarise(sd=round(sd(genic_div_raw),2), value=round(mean(genic_div_raw),2))%>%
  mutate(info="genic_div_raw") %>%
  as.data.frame()

diversity <- rbind(diversity1, diversity2, diversity3) %>%
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


cat("\n\n OUPUT : impact_constraints \n\n")
head(impact_constraints)
tail(impact_constraints)
dim(impact_constraints)
write_delim(impact_constraints, titre_impact_constraints_output, delim = "\t", na = "NA", append = F,  col_names = T, quote_escape = "none")



sessionInfo()