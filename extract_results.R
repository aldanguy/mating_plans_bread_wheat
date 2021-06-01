

Sys.time()
cat("\n\nextract_best_progenies.R\n\n")
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



titre_progenies_tbv_input <- variables[1]
titre_best_progenies_tbv_output <- variables[2]
titre_superior_progenies_tbv_output <- variables[3]
titre_mean_progenies_tbv_output <- variables[4]
titre_parental_lines_tbv_input <- variables[5]
titre_best_parental_lines_tbv_output  <- variables[6]
titre_perf_input <- variables[7]
titre_perf_output <- variables[8]
titre_best_crosses_input <- variables[9]
titre_best_crosses_output <- variables[10]
q <- as.numeric(variables[11])
titre_progenies_sup_best_parent_output <- variables[12]
titre_crosses <- variables[13]




# cat("\n\n INPUT : perf info \n\n")
# perf <- fread(titre_perf_input)
# head(perf)
# tail(perf)
# dim(perf)
# 
# 
# 
# perf <- perf %>%
#   rename(type=V1,
#          sim=V2,
#          qtls=V3,
#          h=V4,
#          r=V5,
#          g=V6,
#          population_variance=V7,
#          critere=V8,
#          programme=V9,
#          progeny=V10,
#          optimization=V11,
#          time=V12,
#          gen=V13,
#          fitness=V14) %>%
#   filter(sim==TRUE) %>%
#   dplyr::select(-progeny, -g, -type, -population_variance, -sim) %>%
#   mutate(r=as.factor(as.numeric(as.character(gsub("r","",r)))))  %>%
#   mutate(h=case_when(is.na(h) ~ "all known",
#                      h==1 ~ "TBV known",
#                      h==0.4 ~ "her=0.4"))%>%
#   ungroup() %>%
#   as.data.frame()  %>%
#   mutate(h=factor(h, levels=c("all known", "TBV known","her=0.4"))) %>%
#   mutate(r=as.factor(r)) %>%
#   mutate(qtls=as.factor(qtls)) %>%
#   mutate(critere=factor(critere, levels=c("gebv","logw","uc","uc_extreme","topq","embv"))) %>%
#   mutate(optimization=as.factor(optimization)) %>%
#   mutate(fitness=as.numeric(fitness)) %>%
#   mutate(programme=as.factor(programme)) %>%
#   filter(ifelse(critere=="logw" & optimization=="GA", F, T)) %>%
#   filter(!is.na(fitness)) %>%
#   filter(is.na(gen) | gen == 20000) %>%
#   unique() %>%
#   arrange(qtls,h, critere,r) %>%
#   as.data.frame()
# 
# 
# cat("\n\n output : performance info \n\n")
# head(perf)
# tail(perf)
# dim(perf)
# write_delim(perf, titre_perf_output, delim = "\t", na = "NA", append = F,  col_names = T, quote_escape = "none")
# 
# 
# 
#  
#  cat("\n\n INPUT : lines info \n\n")
#  progenies_tbv <- fread(titre_progenies_tbv_input) 
#  head(progenies_tbv)
#  tail(progenies_tbv)
#  dim(progenies_tbv)
#  
#  
#  progenies_tbv <- progenies_tbv %>%
#    rename(ID=V1,
#           P1=V2,
#           P2=V3, 
#           type=V4, 
#           sim=V5, 
#           qtls=V6,
#           h=V7,
#           r=V8,
#           rr=V9, 
#           g=V10,
#           population_variance=V11,
#           population_profile=V12,
#           critere=V13, 
#           programme=V14,
#           progeny=V15,
#           value=V16) %>%
#    dplyr::select(-g, -type, -sim, -population_variance, -population_profile, -progeny) %>%
#    mutate(r=as.factor(as.numeric(as.character(gsub("r","",r)))))  %>%
#    mutate(h=case_when(is.na(h) ~ "all known",
#                       h==1 ~ "TBV known",
#                       h==0.4 ~ "her=0.4"))%>%
#    mutate(h=factor(h, levels=c("all known", "TBV known","her=0.4"))) %>%
#    mutate(rr=as.factor(rr)) %>%
#    mutate(critere=factor(critere, levels=c("gebv","logw","uc","uc_extreme","topq","embv"))) %>%
#    mutate(programme=as.factor(programme)) %>%
#    mutate(rr=as.factor(rr)) %>%
#    arrange(qtls, h, r, rr,critere, programme, ID)  %>%
#    unique() %>%
#    ungroup() %>%
#    as.data.frame()
#  
#  
#  progenies_tbv_real <- progenies_tbv %>%
#    filter(!grepl("top","programme")) %>%
#    inner_join(perf, by=c("qtls","h","r","critere","programme")) %>%
#    dplyr::select(-optimization, -time, -gen , -fitness) %>%
#    arrange(qtls, h, r, rr, critere, programme) %>%
#    mutate(programme=as.factor(programme)) %>%
#    filter(!is.na(value))%>%
#    unique() %>%
#    ungroup() %>%
#    as.data.frame()
#  
#  
#  progenies_tbv_top <-progenies_tbv%>%
#    filter(grepl("top",programme)) 
#  
#  
#  progenies_tbv <- rbind(progenies_tbv_real, progenies_tbv_top)
#  
#  
#  rm(progenies_tbv_top, progenies_tbv_real)
#  
#  
# 
#     
#     
#   best_progenies <- progenies_tbv %>%
#     group_by(qtls, h, r, rr, critere, programme) %>%
#     arrange(desc(value), ID) %>%
#     slice(1) %>%
#     arrange(qtls, h, r, rr,critere, programme) %>%
#     ungroup() %>%
#     as.data.frame()%>%
#     unique()
#     
#   
#   cat("\n\n output : best progenies info \n\n")
#   head(best_progenies)
#   tail(best_progenies)
#   dim(best_progenies)
#   write_delim(best_progenies, titre_best_progenies_tbv_output, delim = "\t", na = "NA", append = F,  col_names = T, quote_escape = "none")
#   
#   
#   
#   superior_progenies <- progenies_tbv %>%
#     group_by(qtls, h, r, rr, critere, programme) %>%
#     mutate(q=quantile(value, 1-q)) %>%
#     filter(value >= q) %>%
#     mutate(value=mean(value)) %>%
#     dplyr::select(-q) %>%
#     arrange(qtls, h, r, rr,critere, programme) %>%
#     ungroup() %>%
#     as.data.frame()%>%
#     unique()
#   
#   cat("\n\n output : superior progenies info \n\n")
#   head(superior_progenies)
#   tail(superior_progenies)
#   dim(superior_progenies)
#   write_delim(superior_progenies, titre_superior_progenies_tbv_output, delim = "\t", na = "NA", append = F,  col_names = T, quote_escape = "none")
#   
#   
#   
#   
#   mean_progenies <- progenies_tbv %>%
#     group_by(qtls, h, r, rr, critere, programme) %>%
#     summarise(value=mean(value)) %>%
#     arrange(qtls, h, r, rr,critere, programme) %>%
#     ungroup() %>%
#     as.data.frame()%>%
#     unique()
#   
#   
#   
#   
#   
#   
#     
#     
#   
#   cat("\n\n output : mean progenies info \n\n")
#   head(mean_progenies)
#   tail(mean_progenies)
#   dim(mean_progenies)
#   write_delim(mean_progenies, titre_mean_progenies_tbv_output, delim = "\t", na = "NA", append = F,  col_names = T, quote_escape = "none")
#   
#   rm(best_progenies)
#   rm(superior_progenies)
#   rm(mean_progenies)
# 
# 
#  
#  
#  
  cat("\n\n INPUT : parents info \n\n")
  parental_lines <- fread(titre_parental_lines_tbv_input)
  head(parental_lines)
  tail(parental_lines)
  dim(parental_lines)
  
  
   parental_lines <- parental_lines  %>%
     filter(sim==TRUE & qtls=="300rand" & is.na(h)) %>%
     dplyr::select(-g, -type, -sim, -h) %>%
     mutate(r=as.factor(as.numeric(as.character(gsub("r","",r))))) %>%
      group_by(qtls, r) %>%
      summarise(best_parent=max(value)) %>%
     ungroup() %>%
     as.data.frame() %>%
     unique()
   
   
   
   cat("\n\n output : parents info \n\n")
   head(parental_lines)
   tail(parental_lines)
   dim(parental_lines)
   write_delim(parental_lines, titre_best_parental_lines_tbv_output, delim = "\t", na = "NA", append = F,  col_names = T, quote_escape = "none")
   
#  
#  
#  
#  progenies_sup_best_parent <- progenies_tbv %>%
#    inner_join(parental_lines %>% dplyr::select(-h), by=c("qtls","r")) %>%
#    group_by(qtls, h, r,rr, critere, programme) %>%
#    mutate(nrep=n()) %>%
#    ungroup() %>%
#    filter(value >= best_parent)%>%
#    arrange(qtls, h, r, rr, programme, critere, ID) %>%
#    as.data.frame()
#  
#  
#  cat("\n\n output : progenies sup best parent \n\n")
#  head(progenies_sup_best_parent)
#  tail(progenies_sup_best_parent)
#  dim(progenies_sup_best_parent)
#  write_delim(progenies_sup_best_parent, titre_progenies_sup_best_parent_output, delim = "\t", na = "NA", append = F,  col_names = T, quote_escape = "none")
#  
#  
#  
#  
#  
#  rm(progenies_tbv)
#  rm(parental_lines)
# 
# 
# 
# 
# 
#  
#  rm (perf)
# 
# 



cat ("\n\n best crosses info \n\n")
best_crosses <- fread(titre_best_crosses_input)
head(best_crosses)
tail(best_crosses)
dim(best_crosses)



cat ("\n\n best crosses info \n\n")
crosses <- fread(titre_crosses)
head(crosses)
tail(crosses)
dim(crosses)


best_crosses <- best_crosses %>%
  filter(sim==TRUE & qtls=="300rand") %>%
  dplyr::select(-population_variance, -progeny, -type, -sim) %>%
  mutate(r=as.factor(as.numeric(as.character(gsub("r","",r)))))  %>%
  mutate(h=case_when(is.na(h)~ "all known",
                     h==1 ~ "TBV known",
                     h==0.4 ~ "her=0.4"))%>%
  mutate(h=factor(h, levels=c("all known", "TBV known","her=0.4"))) %>%
  ungroup() %>%
  as.data.frame()



crosses <-  crosses%>%
  filter(sim==TRUE & qtls=="300rand" & is.na(h)) %>%
  dplyr::select(-population_variance, -g, -type, -sim, -h) %>%
  mutate(r=as.factor(as.numeric(as.character(gsub("r","",r)))))   %>%
  dplyr::select(P1, P2, qtls, r, gebv, sd_RILs) %>%
  ungroup() %>%
  as.data.frame()



best_crosses <- best_crosses %>% inner_join(crosses, by=c("P1","P2","qtls","r")) %>%
  dplyr::select(P1, P2, qtls, h, r, critere, programme, nbprogeny, gebv, sd_RILs) %>%
  inner_join(parental_lines, by=c("qtls","r")) %>%
  arrange(qtls, h, r, critere, programme, P1, P2)

rm(crosses)


cat("\n\n output : best crosses info \n\n")
head(best_crosses)
tail(best_crosses)
dim(best_crosses)
write_delim(best_crosses, titre_best_crosses_output, delim = "\t", na = "NA", append = F,  col_names = T, quote_escape = "none")



sessionInfo()