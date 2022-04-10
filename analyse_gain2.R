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
titre_genotypes_parents_input <- variables[4]
titre_markers_input <- variables[5]
titre_parents_input <- variables[6]
titre_selection_rate_output <- variables[7]
titre_diversity_output<- variables[8]
titre_gain_output<- variables[9]



# titre_sel_rate_input <-"/work2/genphyse/dynagen/adanguy/croisements/250222/article/progeny/TBV_progeny_sTRUE_iESTIMATED_q300rand_h0.4_gGBLUP_punselected_n7_mWE_NO_CONSTRAINTS_selection_rate_temp3.txt"
# titre_gain_input <-  "/work2/genphyse/dynagen/adanguy/croisements/250222/article/progeny/TBV_progeny_sTRUE_iESTIMATED_q300rand_h0.4_gGBLUP_punselected_n7_mWE_NO_CONSTRAINTS_gain_temp3.txt"          
# titre_diversity_input <- "/work2/genphyse/dynagen/adanguy/croisements/250222/article/progeny/TBV_progeny_sTRUE_iESTIMATED_q300rand_h0.4_gGBLUP_punselected_n7_mWE_NO_CONSTRAINTS_diversity_temp3.txt"     
# titre_genotypes_parents_input <-  "/work/adanguy/these/croisements/250222/results/genotypes_real_data.txt"                                                                                                         
# titre_markers_input <- "/work2/genphyse/dynagen/adanguy/croisements/250222/article/markers/markers_QTLs_sTRUE_iESTIMATED_q300rand_h0.4_gGBLUP_punselected_n7_mWE_NO_CONSTRAINTS.txt"                    
# titre_parents_input <-"/work2/genphyse/dynagen/adanguy/croisements/250222/article/parents/TBV_first_generation_sTRUE_iESTIMATED_q300rand_h0.4_gGBLUP_punselected_n7_mWE_NO_CONSTRAINTS.txt"  
# 

# titre_sel_rate_input <-  "/work2/genphyse/dynagen/adanguy/croisements/250222/article/progeny/TBV_progeny_sTRUE_iESTIMATED_q300rand_h0.4_gGBLUP_punselected_n1_mWE_CONSTRAINTS_selection_rate_temp3.txt"
# titre_gain_input <- "/work2/genphyse/dynagen/adanguy/croisements/250222/article/progeny/TBV_progeny_sTRUE_iESTIMATED_q300rand_h0.4_gGBLUP_punselected_n1_mWE_CONSTRAINTS_gain_temp3.txt"          
# titre_diversity_input <-  "/work2/genphyse/dynagen/adanguy/croisements/250222/article/progeny/TBV_progeny_sTRUE_iESTIMATED_q300rand_h0.4_gGBLUP_punselected_n1_mWE_CONSTRAINTS_diversity_temp3.txt"     
# titre_genotypes_parents_input <- "/work/adanguy/these/croisements/250222/results/genotypes_real_data.txt"                                                                                                      
# titre_markers_input <-"/work2/genphyse/dynagen/adanguy/croisements/250222/article/markers/markers_QTLs_sTRUE_iESTIMATED_q300rand_h0.4_gGBLUP_punselected_n1_mWE_CONSTRAINTS.txt"                    
# titre_parents_input <- "/work2/genphyse/dynagen/adanguy/croisements/250222/article/parents/TBV_first_generation_sTRUE_iESTIMATED_q300rand_h0.4_gGBLUP_punselected_n1_mWE_CONSTRAINTS.txt"            
# titre_selection_rate_output <- "/work2/genphyse/dynagen/adanguy/croisements/250222/article/progeny/TBV_progeny_sTRUE_iESTIMATED_q300rand_h0.4_gGBLUP_punselected_n1_mWE_CONSTRAINTS_selection_rate_temp4.txt"
# titre_diversity_output<-  "/work2/genphyse/dynagen/adanguy/croisements/250222/article/progeny/TBV_progeny_sTRUE_iESTIMATED_q300rand_h0.4_gGBLUP_punselected_n1_mWE_CONSTRAINTS_diversity_temp4.txt"     
# titre_gain_output<- "/work2/genphyse/dynagen/adanguy/croisements/250222/article/progeny/TBV_progeny_sTRUE_iESTIMATED_q300rand_h0.4_gGBLUP_punselected_n1_mWE_CONSTRAINTS_gain_temp4.txt"          




# titre_sel_rate_input <-  "/work2/genphyse/dynagen/adanguy/croisements/250222/article/progeny/TBV_progeny_sTRUE_iESTIMATED_q300rand_h0.4_gGBLUP_punselected_n20_mWE_CONSTRAINTS_selection_rate_temp3.txt"
# titre_gain_input <- "/work2/genphyse/dynagen/adanguy/croisements/250222/article/progeny/TBV_progeny_sTRUE_iESTIMATED_q300rand_h0.4_gGBLUP_punselected_n20_mWE_CONSTRAINTS_gain_temp3.txt"          
# titre_diversity_input <- "/work2/genphyse/dynagen/adanguy/croisements/250222/article/progeny/TBV_progeny_sTRUE_iESTIMATED_q300rand_h0.4_gGBLUP_punselected_n20_mWE_CONSTRAINTS_diversity_temp3.txt"     
# titre_genotypes_parents_input <- "/work/adanguy/these/croisements/250222/results/genotypes_real_data.txt"                                                                                              
# titre_markers_input <-  "/work2/genphyse/dynagen/adanguy/croisements/250222/article/markers/markers_QTLs_sTRUE_iESTIMATED_q300rand_h0.4_gGBLUP_punselected_n20_mWE_CONSTRAINTS.txt"                    
# titre_parents_input <- "/work2/genphyse/dynagen/adanguy/croisements/250222/article/parents/TBV_first_generation_sTRUE_iESTIMATED_q300rand_h0.4_gGBLUP_punselected_n20_mWE_CONSTRAINTS.txt" 

cat("\n\n INPUT : sel rate \n\n ")
sel <- fread(titre_sel_rate_input)
head(sel)
tail(sel)
dim(sel)


cat("\n\n INPUT : TBV parents \n\n ")
parents <- fread(titre_parents_input)
head(parents)
tail(parents)
dim(parents)

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


cat("\n\n INPUT : markers \n\n ")
m <- fread(titre_markers_input)
head(m)
tail(m)
dim(m)



cat("\n\n INPUT : genotypes parents \n\n ")
g <- fread(titre_genotypes_parents_input)
g %>% dplyr::select(1:10) %>% head()
g %>% dplyr::select(1:10) %>% tail()

dim(g)


gain_parents <- mean(parents$value)

sd_parents <- sd(parents$value)


m2 <- m %>% arrange(chr, dcum, marker) %>% 
  filter(value != 0) %>% 
  dplyr::select(marker, value) 

markers <- m2 %>% 
  dplyr::select(marker) %>%
  unlist() %>%
  as.vector()

values <- m2 %>% 
  dplyr::select(value) %>%
  unlist() %>%
  as.vector()

g2 <- g %>% arrange(ID) %>% dplyr::select(one_of(markers))

maf <- as.vector(apply(g2, 2, function(x) 2*length(which(x==2)) + length(which(x==1)))/(2*nrow(g2)))

genic_div_parents <- sum(4*maf*(1-maf)*(values)^2)

genic_div_parents



sel1 <- sel %>%
  group_by(population, qtls_info, CONSTRAINTS, selection_rate, population_ID) %>%
  mutate(value_ref=ifelse(criterion=="PM", value, NA)) %>%
  mutate(value_ref=max(value_ref, na.rm=T)) %>%
  rowwise() %>%
  mutate(value=((value-value_ref)/(value_ref))) %>%
  as.data.frame() %>%
  dplyr::select(population, criterion, qtls_info, CONSTRAINTS, selection_rate, population_ID, value)
  

# gain1 <- gain %>%
#   group_by(population, qtls_info, CONSTRAINTS, selected_progeny, population_ID) %>%
#   mutate(value_ref=ifelse(criterion=="PM", value, NA)) %>%
#   mutate(value_ref=max(value_ref, na.rm=T)) %>%
#   rowwise() %>%
#   mutate(value=((value-value_ref)/(value_ref-gain_parents))) %>%
#   as.data.frame()%>%
#   dplyr::select(population, criterion, qtls_info, CONSTRAINTS, selected_progeny, population_ID, value)%>%
#   mutate(metric="RI")
# 

gain1 <- gain %>%
  group_by(population, qtls_info, CONSTRAINTS, selected_progeny, population_ID) %>%
  mutate(value_ref=ifelse(criterion=="PM", value, NA)) %>%
  mutate(value_ref=max(value_ref, na.rm=T)) %>%
  rowwise() %>%
  mutate(value=(value-value_ref)/value_ref) %>%
  as.data.frame()%>%
  dplyr::select(population, criterion, qtls_info, CONSTRAINTS, selected_progeny, population_ID, value)%>%
  mutate(metric="RI")


gain2 <- gain %>%
  group_by(population, qtls_info, CONSTRAINTS, selected_progeny, population_ID) %>%
  mutate(value_ref=ifelse(criterion=="PM", value, NA)) %>%
  mutate(value_ref=max(value_ref, na.rm=T)) %>%
  rowwise() %>%
  mutate(value=((value-value_ref)/sd_parents)) %>%
  as.data.frame()%>%
  dplyr::select(population, criterion, qtls_info, CONSTRAINTS, selected_progeny, population_ID, value) %>%
  mutate(metric="sd")


gain3 <- gain %>%
  group_by(population, qtls_info, CONSTRAINTS, selected_progeny, population_ID) %>%
  rowwise() %>%
  mutate(value=((value-gain_parents)/sd_parents)) %>%
  as.data.frame()%>%
  dplyr::select(population, criterion, qtls_info, CONSTRAINTS, selected_progeny, population_ID, value) %>%
  mutate(metric="sd_raw")

gain1 <- rbind(gain1, gain2, gain3)

# 
# diversity1 <- diversity %>%
#   group_by(population, qtls_info, CONSTRAINTS, selected_progeny, population_ID) %>%
#   mutate(genic_div_ref=ifelse(criterion=="PM", genic_div, NA)) %>%
#   mutate(genic_div_ref=max(genic_div_ref, na.rm=T)) %>%
#   rowwise() %>%
#   mutate(genic_div=(genic_div-genic_div_ref)/abs(genic_div_ref-genic_div_parents)) %>%
#   as.data.frame()%>%
#   dplyr::select(population, criterion, qtls_info, CONSTRAINTS, selected_progeny, population_ID, genic_div, nparents)

diversity1 <- diversity %>%
  group_by(population, qtls_info, CONSTRAINTS, selected_progeny, population_ID) %>%
  mutate(genic_div_ref=ifelse(criterion=="PM", genic_div, NA)) %>%
  mutate(genic_div_ref=max(genic_div_ref, na.rm=T)) %>%
  rowwise() %>%
  mutate(genic_div_raw=genic_div/genic_div_parents) %>%
  mutate(genic_div=(genic_div-genic_div_ref)/genic_div_ref) %>%
  as.data.frame()%>%
  dplyr::select(population, criterion, qtls_info, CONSTRAINTS, selected_progeny, population_ID, genic_div, genic_div_raw, nparents)



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
head(diversity1)
tail(diversity1)
dim(diversity1)
write_delim(diversity1, titre_diversity_output, delim = "\t", na = "NA", append = F,  col_names = T, quote_escape = "none")

sessionInfo()