



Sys.time()
cat("\n\nanalyses_rmd.R\n\n")
rm(list = ls())
graphics.off()
set.seed(1)
t1 <- Sys.time()

suppressPackageStartupMessages(library(rmarkdown))
suppressPackageStartupMessages(library(knitr))



variables <- commandArgs(trailingOnly=TRUE)
cat("\n\nVariables : \n")
print(variables)
cat("\n\n")


script=variables[9]
output_dir=variables[10]

rmarkdown::render(script, params=list(titre_crosses_WE=variables[1], 
                                              titre_markers=variables[2],
                                              titre_lines=variables[3],
                                              titre_ped=variables[4],
                                              titre_best_crosses=variables[5],
                                              titre_lines_pred=variables[6],
                                              titre_pedigree_pred=variables[7],
                                              titre_lines_parents=variables[8]),
                  output_file =output_dir)


 
 
 titre_crosses_WE <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/crosses_WE.txt"
 titre_markers <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/markers_estimated.txt"
 titre_lines <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/lines_g2.txt"
 titre_ped <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/pedigree_g2.txt"
 titre_best_crosses <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/best_crosses.txt"
 
 titre_lines_pred <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/lines_g1_simFALSE_allcm_WE_sd_prediction_prefWE_pvarWE.txt"
 titre_pedigree_pred <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/pedigree_g1_simFALSE_allcm_WE_sd_prediction_prefWE_pvarWE.txt"
 titre_lines_parents <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/lines_estimated.txt"

 
l2 <- fread(titre_lines) %>% 
  filter(affixe=="real") %>%
  filter(grepl("simTRUE_allcm_h0.8_r", type)) %>%
  group_by(critere, type, rr) %>% mutate(q= quantile(tbv, 0.93)) %>%
   filter(tbv>=q) %>%
  summarise(m=mean(tbv)) %>%
  mutate(ref=mean(m)) %>%
  mutate(ref2=ifelse(critere=="gebv", ref, NA)) %>%
  group_by(type, rr) %>%
  mutate(ref2=max(ref2, na.rm = T)) %>%
  group_by(type, critere) %>%
  summarise(g=unique((ref-ref2)/ref2)) %>%
  as.data.frame() %>%
  arrange(desc(g))
l2



l2 <- fread(titre_lines) %>% 
  filter(affixe=="real") %>%
  filter(grepl("simTRUE_allcm_h0.8_r", type)) %>%
  group_by(critere, type, rr) %>%
  summarise(m=max(tbv)) %>%
  group_by(critere, type) %>%
  mutate(ref=mean(m)) %>%
  mutate(ref2=ifelse(critere=="gebv", ref, NA)) %>%
  group_by(type, rr) %>%
  mutate(ref2=max(ref2, na.rm = T)) %>%
  group_by(type, critere) %>%
  summarise(g=unique((ref-ref2)/ref2)) %>%
  as.data.frame() %>%
  arrange(desc(g))
l2
