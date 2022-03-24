


Sys.time()
cat("\n\nfirst_selection_cycles.R\n\n")
rm(list = ls())
graphics.off()
set.seed(1)
suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(compiler))
suppressPackageStartupMessages(library(readr))
suppressPackageStartupMessages(library(RandomFieldsUtils))
suppressPackageStartupMessages(library(miraculix))
suppressPackageStartupMessages(library(MoBPS))
suppressPackageStartupMessages(library(synbreed))


variables <- commandArgs(trailingOnly=TRUE)
cat("\n\nVariables : \n")
print(variables)
cat("\n\n")



titre_markers_qtls_input <- variables[1]
titre_tbv_starting_parents_input <-  variables[2]
titre_haplotypes_starting_parents_input <- variables[3]
Kmin <-  as.numeric(variables[4])
selection_rate <-  as.numeric(variables[5])
D <-  as.numeric(variables[6])
nb_cycles <-  as.numeric(variables[7])
titre_tbv_candidate_parents_output <-  variables[8]  
titre_genotypes_candidate_parents_output<-  variables[9]

# 
#  titre_markers_qtls_input <- "/work2/genphyse/dynagen/adanguy/croisements/250222/article/markers/markers_QTLs_sTRUE_iESTIMATED_q300rand_h0.4_gGBLUP_pselected_n1_mWE_CONSTRAINTS.txt"             
#  titre_tbv_starting_parents_input <-  "/work2/genphyse/dynagen/adanguy/croisements/250222/article/parents/TBV_first_generation_sTRUE_iESTIMATED_q300rand_h0.4_gGBLUP_pselected_n1_mWE_CONSTRAINTS.txt"     
#  titre_haplotypes_starting_parents_input <- "/work/adanguy/these/croisements/110222/results/haplotypes_real_data.txt"                                                                                            
#  Kmin <- 300                                                                                                                                                                
#  selection_rate <-0.07                                                                                                                                                               
#  D <-3300                                                                                                                                                      
#  nb_cycles <- 3                                                                                                                                                                  
#  titre_tbv_candidate_parents_output <- "/work2/genphyse/dynagen/adanguy/croisements/250222/article/parents/TBV_last_generation_sTRUE_iESTIMATED_q300rand_h0.4_gGBLUP_pselected_n1_mWE_CONSTRAINTS.txt"      
#  titre_genotypes_candidate_parents_output<- "/work2/genphyse/dynagen/adanguy/croisements/250222/article/parents/genotypes_last_generation_sTRUE_iESTIMATED_q300rand_h0.4_gGBLUP_pselected_n1_mWE_CONSTRAINTS.txt"
#  
# 
# 


# titre_markers_qtls_input <- "/work2/genphyse/dynagen/adanguy/croisements/110222/article/markers/markers_QTLs_sTRUE_iTRUE_q300rand_h1_gNA_pselected_n1_mWE.txt"             
# titre_tbv_starting_parents_input <-  "/work2/genphyse/dynagen/adanguy/croisements/110222/article/parents/TBV_first_generation_sTRUE_iTRUE_q300rand_h1_gNA_pselected_n1_mWE.txt"     
# titre_haplotypes_starting_parents_input <- "/work/adanguy/these/croisements/110222/results/haplotypes_real_data.txt"                                                                      
# Kmin <-   300                                                                                                                                       
# selection_rate <- 0.07                                                                                                                                        
# D <-  3300                                                                                                                                         
# nb_cycles <-  4                                                                                                                                          
# titre_tbv_candidate_parents_output <- "/work2/genphyse/dynagen/adanguy/croisements/110222/article/parents/TBV_last_generation_sTRUE_iTRUE_q300rand_h1_gNA_pselected_n1_mWE.txt"      
# titre_genotypes_candidate_parents_output<- "/work2/genphyse/dynagen/adanguy/croisements/110222/article/parents/genotypes_last_generation_sTRUE_iTRUE_q300rand_h1_gNA_pselected_n1_mWE.txt"
# 
# 



progeny="RILsF8"


cat("\n\n INPUT : markers info \n\n ")
genetic_map <- fread(titre_markers_qtls_input)
head(genetic_map)
tail(genetic_map)
dim(genetic_map)





cat("\n\n INPUT : tbv \n\n ")
starting_parents_tbv <- fread(titre_tbv_starting_parents_input)
head(starting_parents_tbv)
tail(starting_parents_tbv)
dim(starting_parents_tbv)




cat("\n\n INPUT : genotyping \n\n")
starting_parents_haplotypes <- fread(titre_haplotypes_starting_parents_input)
starting_parents_haplotypes %>% select(1:10) %>% head()
starting_parents_haplotypes %>% select(1:10) %>% tail()
starting_parents_haplotypes %>% dim()


seed=unique(starting_parents_tbv$population_ID)
set.seed(seed)

cat("\n\n nb progeny per family \n\n")
nb_progeny <- round(D/Kmin)
nb_progeny

cat("\n\n nb of selected progeny per family \n\n")
number_progeny_selected <- round(nb_progeny*selection_rate)
number_progeny_selected

Pmin=Kmin


cat("\n\n nb of selected progeny per family at last cycle \n\n")
nlines <- nrow(starting_parents_tbv)
number_progeny_selected2 <- floor(nlines/Kmin) +1
number_progeny_selected2

selfing=as.numeric(as.vector(unlist(strsplit(split="F", progeny)))[2])
progeny2=as.vector(unlist(strsplit(split="F", progeny)))[1]





genetic_map <- genetic_map %>%
  arrange(chr, dcum, marker) %>%
  mutate(dcum=dcum/1e2) %>%
  mutate(chr2=as.numeric(as.factor(chr)))



starting_parents_selected <- starting_parents_tbv %>%
  arrange(desc(value)) %>% 
  slice(1:Pmin) %>%
  dplyr::select(ID) %>%
  unlist() %>% 
  as.vector() %>%
  sort()



haplotypes_parents <- starting_parents_haplotypes %>% 
  filter(ID %in% !!starting_parents_selected) %>%
  dplyr::select(-ID)  %>%
  column_to_rownames("haplo")  %>%
  dplyr::select(one_of(genetic_map$marker)) %>%
  t()   




cat("\n\n total genetic variance at gen 0\n\n")
variance_initial <- var(starting_parents_tbv$value)
variance_initial






# parameters for MOPBS
sex1=1 # sex of parent P1 (male)
sex2=sex1 # sex of parent P2 (male)
sex.probability=0  # probability that the offspring will be a female
gen1=1 # generation from which P1 belongs to
gen2=gen1 # generation from which P2 belongs to



cycle=0
 

for (cycle in 1:nb_cycles){
  
  
  if (cycle < nb_cycles){
    number_progeny_selected3 <- number_progeny_selected
  } else {
    
    number_progeny_selected3 <- number_progeny_selected2
    
  }
  
  print(cycle)
  

  
  
 
  random_matings <- data.frame(parent1=1:Pmin) %>%
    rowwise() %>%
    mutate(parent2=sample(1:Pmin %>% as.data.frame() %>%slice(-parent1) %>% unlist() %>% as.vector(), size=1)) %>%
    mutate(parent2=ifelse(parent1==parent2, sample(1:Pmin, size=1, replace = F), parent2)) %>%
    mutate(parent3=min(parent1, parent2), parent4=max(parent1, parent2)) %>%
    dplyr::select(parent3, parent4) %>%
    rename(parent1=parent3, parent2=parent4)%>%
    mutate(gen1=!!gen1, sex1=!!sex1, gen2=!!gen2, sex2=!!sex2, sex.probability=!!sex.probability) %>%
    dplyr::select(gen1, sex1,parent1, gen2, sex2, parent2, sex.probability ) %>%
    unlist() %>%
    as.vector() %>%
    matrix(., nrow=Kmin, byrow=F)
  
  
  

  parents <- creating.diploid(dataset = haplotypes_parents , 
                              sex.quota = F, # all individiuals are considered as males
                              snp.name=genetic_map$marker, 
                              chr.nr=genetic_map$chr2, 
                              snp.position = genetic_map$dcum, 
                              name.cohort="Parents",
                              verbose = F) # ignore warnings
  
  
  
  
  
  haplo_selected_progeny <- data.frame(v1=rep(NA, times=nrow(genetic_map)))
  # haplotypes_all <-data.frame(v1=rep(NA, times=nrow(genetic_map)))
  
  i=1
  
  
  for (i in 1:Kmin){
    
    f1=breeding.diploid(parents, 
                        name.cohort ="F1",
                        breeding.size = c(nb_progeny,0),
                        repeat.mating = nb_progeny,  
                        fixed.breeding=t(random_matings[i,]),
                        mutation.rate = 0,    
                        remutation.rate = 0,
                        verbose=F,
                        miraculix.cores = 1)
    
    
    pop=f1
    
    for(generation in 1:selfing){
      
      pop=breeding.diploid(pop, breeding.size = c(nb_progeny,0), 
                           max.offspring = 1, 
                           repeat.mating = 1,  
                           mutation.rate = 0, 
                           remutation.rate = 0,
                           selfing.mating = TRUE, 
                           miraculix.cores = 1,
                           selfing.sex = 0,
                           verbose=F)
      
    }
    
    
    
    geno <- get.geno(pop, gen=selfing+2)
    
    ID_progeny <- paste0(paste0("p", 1:nb_progeny, "_k", i, "_c", cycle),"_XXX")
    ID_progeny <- gsub("\\s", "0", format(ID_progeny, width=max(nchar(starting_parents_tbv$ID))))
    
    colnames(geno) <- ID_progeny
    
    
    haplo <- get.haplo(pop, gen=selfing+2)
    colnames(haplo) <- paste0(rep(ID_progeny, each=2), c("_haplo1","_haplo2"))
    

    
    TBV_progeny <- crossprod(geno, genetic_map$value)
    
    

      
      ID_selected_progeny <- colnames(geno)[order(TBV_progeny, decreasing = T)[1:number_progeny_selected3]]
      
  
    
    
    haplo_selected_progeny <- cbind(haplo_selected_progeny, haplo %>% as.data.frame() %>% dplyr::select(starts_with(ID_selected_progeny)))
   
    
    
  }
  
  
  haplotypes_parents <- haplo_selected_progeny[, -1]
 
  

  
  
}



geno_parents <- haplotypes_parents %>% 
  t() %>% 
  as.data.frame() %>% 
  rownames_to_column("ID") %>%
  mutate(ID=as.vector(unlist(strsplit(ID, split="_haplo")))[seq(1, nrow(.)*2, 2)]) %>%
  group_by(ID) %>%
  summarise_at(vars(starts_with("AX")), funs(sum(.))) %>%
  as.data.frame()   %>%
  mutate(parent=!!starting_parents_tbv$ID[1]) %>%
  inner_join(starting_parents_tbv %>% dplyr::select(-one_of("info", "value")), by=c("parent"="ID"))%>%
  mutate(population="selected") %>%
  arrange(ID) %>%
  dplyr::select(ID,  simulation, qtls, qtls_info, heritability, population, population_ID, one_of(genetic_map$marker))

  



TBV <- crossprod(geno_parents %>% dplyr::select(starts_with("AX")) %>% t(), genetic_map$value)




parental_tbv <- data.frame(value=TBV) %>%
  mutate(ID=!!geno_parents$ID) %>%
  mutate(parent=!!starting_parents_tbv$ID[1]) %>%
  inner_join(starting_parents_tbv %>% dplyr::select(-one_of("info", "value")), by=c("parent"="ID"))%>%
  mutate(population="selected") %>%
  mutate(info="TBV") %>%
  arrange(ID) %>%
  dplyr::select(ID, value, info, simulation, qtls, qtls_info, heritability, population, population_ID)



# parental_tbv <- parental_tbv %>%
#   arrange(desc(value)) %>%
#   slice(1:nrow(starting_parents_tbv)) %>%
#   arrange(ID)



parental_tbv <- parental_tbv %>%
  slice(sort(sample(1:nrow(starting_parents_tbv), size=nrow(starting_parents_tbv), replace = F))) %>%
  arrange(ID) 


geno_parents <- geno_parents %>%
  filter(ID %in% !!parental_tbv$ID) %>%
  arrange(ID)



var(parental_tbv$value)



cat("\n\n genotypes of parents \n\n")
geno_parents %>% dplyr::select(1:10) %>% head()
geno_parents %>% dplyr::select(1:10) %>% tail()
dim(geno_parents)
write_delim(geno_parents, titre_genotypes_candidate_parents_output, delim = "\t", na = "NA", append = F,  col_names = T, quote_escape = "none")








cat("\n\n parental TBV \n\n")
head(parental_tbv)
tail(parental_tbv)
dim(parental_tbv)
write_delim(parental_tbv, titre_tbv_candidate_parents_output, delim = "\t", na = "NA", append = F,  col_names = T, quote_escape = "none")




sessionInfo()