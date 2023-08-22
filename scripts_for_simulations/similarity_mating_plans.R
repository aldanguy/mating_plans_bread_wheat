

Sys.time()
cat("\n\nsimilarity_mating_plans.R\n\n")
rm(list = ls())
graphics.off()
set.seed(1)

suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(compiler))



variables <- commandArgs(trailingOnly=TRUE)
cat("\n\nVariables : \n")
print(variables)
cat("\n\n")



titre_LDAK_input <- variables[1]
titre_mating_plan1_input <- variables[2]
titre_mating_plan2_input <- variables[3]
criterion1 <- variables[4]
criterion2 <- variables[5]
titre_similarity_output <-  variables[6]


# titre_LDAK_input <-  "/work/adanguy/these/croisements/250222/results/LDAK_real_data.txt"                                                                                                             
# titre_mating_plan1_input <-"/work2/genphyse/dynagen/adanguy/croisements/250222/article/optimization/mating_plan_sTRUE_iESTIMATED_q300rand_h0.4_gGBLUP_punselected_n9_mWE_CONSTRAINTS_UC1.txt"              
# titre_mating_plan2_input <- "/work2/genphyse/dynagen/adanguy/croisements/250222/article/optimization/mating_plan_sTRUE_iESTIMATED_q300rand_h0.4_gGBLUP_punselected_n9_mWE_CONSTRAINTS_UC2.txt"              
# criterion1 <- "UC1"                                                                                                                                                                           
# criterion2 <- "UC2"                                                                                                                                                                           
# # 




cat("\n\n INPUT : mating plan 1 \n\n")
m1 <- fread(titre_mating_plan1_input)  
head(m1)
tail(m1)
dim(m1)

cat("\n\n INPUT : mating plan 2 \n\n")
m2 <- fread(titre_mating_plan2_input)  
head(m2)
tail(m2)
dim(m2)


cat("\n\n INPUT : LDAK \n\n")
ldak <- fread(titre_LDAK_input)  
head(ldak)
tail(ldak)
dim(ldak)

parents <- ldak %>% dplyr::select(P1, P2) %>% unlist() %>% unlist() %>%
  unique() %>%
  as.vector()

d <- data.frame(P=parents)


ldak2 <- ldak %>% dplyr::select(P1, P2, value, info) %>%
  filter(P1 != P2) %>%
  rename(Pa=P2, Pb=P1) %>%
  dplyr::select(Pa, Pb, value, info) %>%
  rename(P1=Pa, P2=Pb)

ldak <- ldak %>% dplyr::select(P1, P2, value, info)

ldak <- rbind(ldak, ldak2)

c1 <- m1 %>%
  dplyr::select(P1, P2, nbprogeny) %>%
  pivot_longer(cols=c("P1","P2"), values_to = "P") %>%
  dplyr::select(-name) %>%
  group_by(P) %>%
  summarise(nbprogeny=sum(nbprogeny)) %>%
  ungroup() %>%
  mutate(n=sum(nbprogeny)) %>%
  mutate(c=nbprogeny/n) %>%
  dplyr::select(P, c) %>%
  full_join(d, by="P") %>%
  as.data.frame() %>%
  mutate_at(vars(c), funs(replace_na(., 0)))
  
  


c2 <- m2 %>%
  dplyr::select(P1, P2, nbprogeny) %>%
  pivot_longer(cols=c("P1","P2"), values_to = "P") %>%
  dplyr::select(-name) %>%
  group_by(P) %>%
  summarise(nbprogeny=sum(nbprogeny)) %>%
  ungroup() %>%
  mutate(n=sum(nbprogeny)) %>%
  mutate(c=nbprogeny/n) %>%
  dplyr::select(P, c) %>%
  as.data.frame()%>%
  full_join(d, by="P") %>%
  as.data.frame() %>%
  mutate_at(vars(c), funs(replace_na(., 0)))






numerateur <- ldak %>% dplyr::select(P1, P2, value) %>%
  full_join(c1, by=c("P1"="P")) %>%
  full_join(c2, by=c("P2"="P")) %>%
  rename(c1=c.x, c2=c.y)%>%
  mutate_all(funs(replace_na(., 0)))%>%
  mutate(c1c2=value*c1*c2) %>%
  summarise(similarity=sum(c1c2)) %>%
  unlist() %>%
  as.vector()



if (criterion1 != criterion2){

  
  
  denominateur1 <- ldak %>% dplyr::select(P1, P2, value) %>%
    full_join(c1, by=c("P1"="P")) %>%
    full_join(c1, by=c("P2"="P")) %>%
    rename(c1=c.x, c2=c.y)%>%
    mutate_all(funs(replace_na(., 0)))%>%
    mutate(c1c2=value*c1*c2) %>%
    summarise(similarity=sqrt(sum(c1c2))) %>%
    unlist() %>%
    as.vector()
  
  denominateur2 <- ldak %>% dplyr::select(P1, P2, value) %>%
    full_join(c2, by=c("P1"="P")) %>%
    full_join(c2, by=c("P2"="P")) %>%
    rename(c1=c.x, c2=c.y)%>%
    mutate_all(funs(replace_na(., 0)))%>%
    mutate(c1c2=value*c1*c2) %>%
    summarise(similarity=sqrt(sum(c1c2))) %>%
    unlist() %>%
    as.vector()
  
  
  
similarity <- numerateur/(denominateur1*denominateur2)


} else {
  
  
  nparents <- ldak %>% dplyr::select(P1, P2) %>%
    unlist() %>%
    as.vector() %>%
    unique() %>%
    length()
  
  
  denominateur3 <- ldak %>% dplyr::select(P1, P2, value) %>%
    mutate(c1=1/nparents) %>%
    mutate(c2=c1)%>%
    mutate_all(funs(replace_na(., 0)))%>%
    mutate(c1c2=value*c1*c2) %>%
    summarise(similarity=sum(c1c2))
  
  similarity <- numerateur
  
  
}


parents_in_common <- m1 %>% dplyr::select(P1, P2, criterion, nbprogeny) %>%
  rbind(m2 %>% dplyr::select(P1, P2, criterion, nbprogeny)) %>%
  pivot_longer(cols = c("P1","P2"), values_to = "P", names_to = "name") %>%
  dplyr::select(-name) %>%
  group_by(criterion, P) %>%
  summarise(nbprogeny=sum(nbprogeny)) %>%
  ungroup() %>%
  pivot_wider(id_cols = c("P"), values_from = "nbprogeny", names_from = "criterion") %>%
  mutate_all(list(~replace_na(., 0))) %>%
  rename_at(vars(one_of(criterion1)), ~ "criterion1")%>%
  rename_at(vars(one_of(criterion2)), ~ "criterion2") %>%
  mutate(ntot=n()) %>%
  filter(criterion1 > 0 & criterion2 > 0) %>%
  summarise(n=n()/ unique(ntot)) %>%
  unlist() %>%
  as.vector()



crosses_in_common <- m1 %>% dplyr::select(P1, P2, criterion, nbprogeny) %>%
  mutate(cross=paste0(P1, P2)) %>%
  rbind(m2 %>% dplyr::select(P1, P2, criterion, nbprogeny) %>%  mutate(cross=paste0(P1, P2))) %>%
  pivot_longer(cols = c("cross"), values_to = "C", names_to = "name") %>%
  dplyr::select(-name) %>%
  group_by(criterion, C) %>%
  summarise(nbprogeny=sum(nbprogeny)) %>%
  ungroup() %>%
  pivot_wider(id_cols = c("C"), values_from = "nbprogeny", names_from = "criterion") %>%
  mutate_all(list(~replace_na(., 0))) %>%
  rename_at(vars(one_of(criterion1)), ~ "criterion1")%>%
  rename_at(vars(one_of(criterion2)), ~ "criterion2") %>%
  mutate(ntot=n()) %>%
  filter(criterion1 > 0 & criterion2 > 0) %>%
  summarise(n=n()/ unique(ntot)) %>%
  unlist() %>%
  as.vector()











output <- data.frame(criterion1=criterion1,
                criterion2=criterion2,
                metric=c("similarity", "parents", "crosses"),
                value=c(similarity, parents_in_common, crosses_in_common)) %>%
  mutate(P1=m1$P1[1], P2=m1$P2[1]) %>%
  inner_join(m1 %>% dplyr::select(-one_of("criterion", "nbprogeny")), by=c("P1", "P2")) %>%
  dplyr::select(-P1, -P2)











cat("\n\n OUPUT : similarity \n\n")
head(output)
dim(output)
write.table(output, titre_similarity_output, col.names = T, row.names = F, dec=".", sep="\t", quote=F)



sessionInfo()