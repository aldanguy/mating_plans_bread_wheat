

Sys.time()
cat("\n\nresultats.R\n\n")
rm(list = ls())
graphics.off()
set.seed(1)

suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(compiler))
suppressPackageStartupMessages(library(viridis))
suppressPackageStartupMessages(library(ggpubr))
suppressPackageStartupMessages(library(igraph))
suppressPackageStartupMessages(library(pheatmap))
suppressPackageStartupMessages(library(cowplot))

library(gridExtra)
library(grid)
library(ggplot2)
library(lattice)



titre_best_progenies <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/sample_progenies_tbv.txt"

titre_crosses <-  "/home/adanguydesd/Documents/These_Alice/croisements/temp/best_crosses2.txt"

crosses <- fread(titre_crosses) %>%
  mutate(embv=gebv+2.29420984716186*sd_RILs) %>%
  filter(qtls=="300rand" & h=="all known" & r==1 & programme=="real")


best_progenies <- fread(titre_best_progenies) %>%
  rename(P1=V2, P2=V3, value=V16, critere=V13) %>%
  dplyr::select(P1, P2, value, critere) 


test <- best_progenies %>% inner_join(crosses, by=c("P1","P2", "critere")) 

data <- test %>%
  group_by(P1, P2) %>%
  mutate(n=n())%>%
  arrange(desc(n)) %>%
  filter(n >=1000) %>%
  ungroup() %>%
  dplyr::select(P1, P2, value)



vecteur <- data.frame()
for (step in 1:100){
  
 vecteur <- rbind(vecteur, data %>% group_by(P1, P2) %>%
                slice(sort(sample(1:n(), size=60, replace = F))) %>%
                summarise(max=max(value)) %>% ungroup() %>% as.data.frame())
  
  
}


vecteur %>%
  group_by(P1, P2) %>%
  summarise(mean_value=mean(max)) %>%
  inner_join(crosses %>% dplyr::select(P1, P2, embv) %>% unique(), by=c("P1","P2"))  %>%
  ggplot(aes(x=embv, y=mean_value)) +
  geom_point()+
  geom_abline(slope=1, intercept = 0, col="red")
