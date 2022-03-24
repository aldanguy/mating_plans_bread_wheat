Sys.time()
cat("\n\analyse_replicate.R\n\n")
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







titre_mating_plans_input <- variables[1]
titre_shared_output <- variables[2]

#titre_mating_plans_input <- "/work2/genphyse/dynagen/adanguy/croisements/250222/article/replicate/mating_plan_replicate.txt"

cat("\n\n INPUT : mating plans \n\n ")
m <- fread(titre_mating_plans_input)
head(m)
tail(m)
dim(m)


m2 <- m %>%
  dplyr::select(P1, P2, nbprogeny, criterion, CONSTRAINTS, qtls_info, population, population_ID, rep) %>%
  mutate(P1=as.factor(P1), P2=as.factor(P2), criterion=as.factor(criterion), CONSTRAINTS=as.factor(CONSTRAINTS),
         qtls_info=as.factor(qtls_info), population=as.factor(population), population_ID=as.factor(population_ID), seed=as.factor(seed))



population="unselected"

population_ID="1"

CONSTRAINTS="CONSTRAINTS"

qtls_info="TRUE"

criterion="UC1"

rep1="rep1"

rep2="rep2"

temp <- data.frame()

for (population in unique(m2$population)){
  
  for (qtls_info in unique(m2$qtls_info)){
    
    for (population_ID in unique(m2$population_ID)){
      
      for (CONSTRAINTS in unique(m2$CONSTRAINTS)){
        
        for (criterion in unique(m2$criterion)){
          
          for (rep1 in unique(m2$seed)){
            
            for (rep2 in unique(m2$seed)){
              
            
            
            
            mt <- m2 %>%
              filter(population==!!population,
                     population_ID==!!population_ID,
                     CONSTRAINTS==!!CONSTRAINTS,
                     qtls_info==!!qtls_info,
                     seed %in% c(seed1, seed2),
                     criterion == !!criterion)
            
            
            
            parents <- mt %>%
              pivot_longer(cols = c("P1","P2"), names_to = "name", values_to = "P") %>%
              dplyr::select(-name) %>%
              group_by(P, seed) %>%
              summarise(nbprogeny=sum(nbprogeny)) %>%
              ungroup() %>%
              pivot_wider(id_cols = c("P"), names_from = "seed", values_from = "nbprogeny") %>%
              mutate_all(funs(replace_na(., 0))) %>%
              rename_at(vars(one_of(rep1)), ~ "rep1")%>%
              rename_at(vars(one_of(rep2)), ~ "rep2") %>%
              mutate(shared=ifelse(rep1>0 & rep2 >0, 1, 0)) %>%
              summarise(value=sum(shared)/n())
            
            
              crosses <- mt %>%
              mutate(crosses=paste0(P1, P2)) %>%
              dplyr::select(-P1, -P2) %>%
              pivot_wider(id_cols = c("crosses"), names_from = "seed", values_from = "nbprogeny") %>%
              mutate_all(funs(replace_na(., 0))) %>%
              rename_at(vars(one_of(rep1)), ~ "rep1")%>%
              rename_at(vars(one_of(rep2)), ~ "rep2") %>%
              mutate(shared=ifelse(rep1>0 & rep2 >0, 1, 0)) %>%
              summarise(value=sum(shared)/n())
            
            
            parentst <- data.frame(population=population,
                                   population_ID=population_ID,
                                   CONSTRAINTS=CONSTRAINTS,
                                   qtls_info=qtls_info,
                                   criterion=criterion,
                                   rep1=rep1,
                                   rep2=rep2,
                                   value=parents*100,
                                   metric="parents")
            
            crossest <- data.frame(population=population,
                                   population_ID=population_ID,
                                   CONSTRAINTS=CONSTRAINTS,
                                   qtls_info=qtls_info,
                                   criterion=criterion,
                                   rep1=rep1,
                                   rep2=rep2,
                                   value=crosses*100,
                                   metric="crosses")
            
            temp <- rbind(temp, parentst, crossest)
            
            
            
            
            
          }
          
          
          
          
          
          
        }
      }
    }
  }
  
}

}

order_rep <- data.frame(rep=unique(m2$seed), ordre=1:length(unique(m2$seed)))


shared <- temp %>%
  inner_join(order_rep, by=c("rep1"="rep"))%>%
  inner_join(order_rep, by=c("rep2"="rep")) %>%
  rename(ordre1=ordre.x)%>%
  rename(ordre2=ordre.y) %>%
  mutate(repA=ifelse(ordre1 <= ordre2, as.character(rep1), as.character(rep2))) %>%
  mutate(repB=ifelse(ordre1 > ordre2, as.character(rep1), as.character(rep2))) %>%
  dplyr::select(-rep1, -rep2, -ordre1, -ordre2) %>%
  rename(rep1=repA, rep2=repB) %>%
  unique() %>%
  filter(rep1 != rep2) %>%
  group_by(population, CONSTRAINTS, qtls_info, metric, criterion) %>%
  summarise(shared=round(mean(value)), sd=round(sd(value))) %>%
  as.data.frame()

cat("\n\n OUPUT : shared \n\n")
head(shared)
tail(shared)
dim(shared)
write_delim(shared, titre_shared_output, delim = "\t", na = "NA", append = F,  col_names = T, quote_escape = "none")


sessionInfo()