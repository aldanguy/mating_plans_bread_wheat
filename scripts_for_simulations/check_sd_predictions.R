


Sys.time()
cat("\n\ncheck_sd_predictions.R\n\n")
rm(list = ls())
graphics.off()
set.seed(1)
t1 <- Sys.time()

suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(compiler))
suppressPackageStartupMessages(library(ggpubr))


variables <- commandArgs(trailingOnly=TRUE)
cat("\n\nVariables : \n")
print(variables)
cat("\n\n")






titre_lines_input <- variables[1]
titre_pedigree_input <- variables[2]
titre_crosses_input <- variables[3]
selection_treshold_PROBA <- as.numeric(variables[4])
Dmax_EMBV <- as.numeric(variables[5])
within_family_selection_rate_UC1 <- as.numeric(variables[6])
within_family_selection_rate_UC2 <- as.numeric(variables[7])
titre_graph <- variables[8]

# 
# titre_lines_input <- "/work2/genphyse/dynagen/adanguy/croisements/110222/article/progeny/TBV_progeny_sTRUE_iTRUE_q300rand_h1_gNA_pselected_n1_mWE_sd_prediction_1.txt"             
# titre_pedigree_input <- "/work2/genphyse/dynagen/adanguy/croisements/110222/article/progeny/results/pedigree_progeny_sTRUE_iTRUE_q300rand_h1_gNA_pselected_n1_mWE_sd_prediction_1.txt"
# titre_crosses_input <-  "/work2/genphyse/dynagen/adanguy/croisements/110222/article/crosses/crosses_NO_CONSTRAINTS_sTRUE_iTRUE_q300rand_h1_gNA_pselected_n1_mWE.txt"                  
# selection_treshold_PROBA <-27.282439812158003                                                                                                                                        
# Dmax_EMBV <-10                                                                                                                                                        
# within_family_selection_rate_UC1 <-0.07                                                                                                                                                        
# within_family_selection_rate_UC2 <-0.0001                                                                                                                                                      
# titre_graph <-"/work/adanguy/these/croisements/110222/graphs/sd_predictions_sTRUE_iTRUE_q300rand_h1_gNA_pselected_n1_mWE.png"                                               
# 




cat("\n\n lines info \n\n")
l <- fread(titre_lines_input)
head(l)
tail(l)
dim(l)

cat("\n\n crosses info \n\n")

crosses <- fread(titre_crosses_input)
head(crosses)
tail(crosses)
dim(crosses)



cat("\n\n parental lines info \n\n")

ped <- fread(titre_pedigree_input)
head(ped)
tail(ped)
dim(ped)




l2 <- l %>%
  dplyr::select(ID, value) %>%
  inner_join(ped %>% dplyr::select(P1, P2, ID), by="ID") %>%
  group_by(P1, P2) 

criteria <- l2 %>%
  mutate(PM=mean(value))%>%
  mutate(sd=sd(value))%>%
  mutate(q1=quantile(value, 1-within_family_selection_rate_UC1)) %>%
  mutate(uc1_temp=ifelse(value >= q1, value, NA)) %>%
  mutate(UC1=mean(uc1_temp, na.rm = T))%>%
  mutate(q2=quantile(value, 1-within_family_selection_rate_UC2)) %>%
  mutate(uc2_temp=ifelse(value >= q2, value, NA)) %>%
  mutate(UC2=mean(uc2_temp, na.rm = T))%>%
  mutate(UC2=mean(uc2_temp, na.rm = T)) %>%
  mutate(PROBA = length(which(value >= selection_treshold_PROBA))/n()) %>%
  mutate(OHV=max(value)) %>%
  ungroup() %>%
  dplyr::select(P1, P2, PM, sd, UC1, UC2, PROBA, OHV) %>%
  unique()
    
EMBV <- data.frame()

for (i in 1:10){
  
  EMBV_temp <- l2 %>%
    slice(sample(1:n(), size=Dmax_EMBV, replace=F)) %>%
    arrange(desc(value)) %>%
    slice(1) %>%
    rename(EMBV=value) %>%
    dplyr::select(P1, P2, EMBV)%>%
    ungroup()
  
  
  EMBV <- rbind(EMBV_temp, EMBV)
  
  
  
}






observed <- EMBV %>% 
  group_by(P1, P2) %>%
  summarise(EMBV=mean(EMBV)) %>%
  ungroup() %>%
  dplyr::select(P1, P2, EMBV) %>%
  inner_join(criteria, by=c("P1","P2"))%>%
  dplyr::select(P1, P2, PM, sd, UC1, UC2, PROBA, OHV, EMBV) %>%
  pivot_longer(cols=c("sd","PM","UC1","UC2","OHV","EMBV","PROBA"), names_to = "criterion", values_to = "observed")


predicted <- crosses %>%
  dplyr::select(P1, P2, PM, sd, UC1, UC2, PROBA, EMBV, OHV) %>%
  rowwise() %>%
  mutate(PROBA=pnorm(selection_treshold_PROBA, PM, sd, lower.tail = F)) %>%
  ungroup()%>%
  pivot_longer(cols=c("sd","PM","UC1","UC2","OHV","EMBV","PROBA"), names_to = "criterion", values_to = "predicted")


final <- predicted %>%
  inner_join(observed, by=c("P1", "P2", "criterion")) %>%
  as.data.frame() %>%
  mutate(criterion=factor(criterion, levels = c("sd","PM","UC1","UC2","PROBA","EMBV", "OHV")))
              
graph <- final %>%
  ggplot(aes(x=predicted, y=observed)) +
  geom_point() +
  geom_abline(slope=1, intercept = 0, col="red") +
  facet_wrap(.~criterion, scales = "free") +
  theme_light()+
  theme(plot.title = element_text(hjust = 0.5),
        axis.text.y = element_text(size=12),
        axis.title.y = element_text(size=20),
        axis.text.x = element_text(size=12, angle=45),
        legend.text=element_text(size=12),
        legend.title=element_text(size=20),
        strip.text.x = element_text(size = 20, color="black"),
        strip.text.y = element_text(size = 20, color="black"),
        strip.background = element_rect(color="black", fill="white"),
        panel.grid.minor = element_blank(),
        axis.title.x = element_text(size=20)) 


ggsave(titre_graph, graph)

cat("\n\n comparison \n\n")
head(final)
tail(final)
dim(final)

sessionInfo()