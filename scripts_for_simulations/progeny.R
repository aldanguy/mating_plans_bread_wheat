Sys.time()
cat("\n\nprogeny.R\n\n")
rm(list = ls())
graphics.off()
set.seed(1)
t1 <- Sys.time()

suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(compiler))
suppressPackageStartupMessages(library(readr))
suppressPackageStartupMessages(library(RandomFieldsUtils))
suppressPackageStartupMessages(library(miraculix))
suppressPackageStartupMessages(library(MoBPS))



variables <- commandArgs(trailingOnly=TRUE)
cat("\n\nVariables : \n")
print(variables)
cat("\n\n")







titre_markers_input <- variables[1]
titre_mating_plan_input <- variables[2]
titre_haplo_input <- variables[3]
num_simulation  <- as.numeric(variables[4])
titre_genotypes_output <- variables[5] # output
titre_pedigree_output <- variables[6] 




# titre_markers_input <-"/work2/genphyse/dynagen/adanguy/croisements/250222/article/markers/markers_QTLs_sTRUE_iTRUE_q300rand_hNA_gNA_punselected_n1_mWE_CONSTRAINTS.txt"                                                                                        
# titre_mating_plan_input <- "/work/adanguy/these/croisements/250222/results/mating_plan_sTRUE_iTRUE_q300rand_hNA_gNA_punselected_n1_mWE_CONSTRAINTS_EMBV.txt"                                                                                                        
# titre_haplo_input <- "/work/adanguy/these/croisements/250222/results/haplotypes_real_data.txt"                                                                                                                                                                
# num_simulation  <-1                                                                                                                                                                                                                                     
# titre_genotypes_output <-  "/work2/genphyse/dynagen/adanguy/croisements/250222/article/progeny/temp/sTRUE_iTRUE_q300rand_hNA_gNA_punselected_n1_mWE_CONSTRAINTS_EMBV_1/genotypes_progeny_sTRUE_iTRUE_q300rand_hNA_gNA_punselected_n1_mWE_CONSTRAINTS_EMBV_1.txt"    
# titre_pedigree_output <- "/work2/genphyse/dynagen/adanguy/croisements/250222/article/progeny/temp/sTRUE_iTRUE_q300rand_hNA_gNA_punselected_n1_mWE_CONSTRAINTS_EMBV_1/pedigree_progeny_temp_sTRUE_iTRUE_q300rand_hNA_gNA_punselected_n1_mWE_CONSTRAINTS_EMBV_1.txt"
# 

set.seed(num_simulation)


cat("\n\n INPUT : markers info \n\n ")
genetic_map <- fread(titre_markers_input) %>% arrange(chr, dcum)
head(genetic_map)
tail(genetic_map)
dim(genetic_map)



cat("\n\n INPUT : best crosses \n\n ")
mating_plan <- fread(titre_mating_plan_input) 
head(mating_plan)
tail(mating_plan)
dim(mating_plan)
mating_plan <- mating_plan 



cat("\n\n INPUT : genotyping \n\n")
haplotypes <- fread(titre_haplo_input)
haplotypes %>% dplyr::select(1:10) %>% head()
haplotypes %>% dplyr::select(1:10) %>% tail()
haplotypes %>% dim()









progeny=unique(mating_plan$progeny)
selfing=as.numeric(as.vector(unlist(strsplit(split="F", progeny)))[2])
progeny2=as.vector(unlist(strsplit(split="F", progeny)))[1]



liste_lines <- mating_plan %>%
  arrange(P1, P2) %>%
  dplyr::select(P1, P2) %>%
  unlist() %>% 
  as.vector() %>% 
  unique() %>% 
  sort()



genetic_map <- genetic_map %>%
  arrange(chr, dcum, marker) %>%
  mutate(dcum=dcum/1e2) %>%
  mutate(chr2=as.numeric(as.factor(chr)))




haplotypes <- haplotypes %>%
  filter(ID %in% !!liste_lines) %>%
  arrange(ID, haplo)








liste_lines2 <- haplotypes %>% #to have order of parents in haplotypes
  dplyr::select(ID) %>%
  arrange(ID) %>%
  unlist() %>%
  as.vector() %>%
  unique()


# genetic map
# input for MOBPS







parents <- creating.diploid(dataset = haplotypes %>%
                              dplyr::select(ID, haplo, one_of(genetic_map$marker)) %>%
                              column_to_rownames("haplo") %>%
                              dplyr::select(-ID) %>%
                              t()    , 
                            sex.quota = F, # all individiuals are considered as males
                            snp.name=genetic_map$marker, 
                            chr.nr=genetic_map$chr2, 
                            snp.position = genetic_map$dcum, 
                            name.cohort="Parents",
                            verbose = F) # ignore warnings
# rm(haplotypes)
# parents$info$chromosome
# parents$info$bp
# parents$info$snp
# parents$info$position[[1]] %>% head()
# get.geno(parents, gen=1)[1:10,]


# parameters for MOPBS
sex1=1 # sex of parent P1 (male)
sex2=sex1 # sex of parent P2 (male)
sex.probability=0  # probability that the offspring will be a female
gen1=1 # generation from which P1 belongs to
gen2=gen1 # generation from which P2 belongs to



i=1
progeny_genotypes <- data.frame()
for ( i in 1:nrow(mating_plan)){
  
  #print(i)
  
  
  #print(i)
  
  
  
  
  parent1 = which(liste_lines2 %in% mating_plan$P1[i]) # ID of P1
  parent2 = which(liste_lines2 %in% mating_plan$P2[i]) # ID of P2
  d=floor(mating_plan$nbprogeny[i])
  
  cr1=matrix(c(gen1,sex1,parent1,gen2,sex1,parent2,sex.probability),nrow=1,byrow=T) # indicate to MOPBS which parental lines to cross
  
  if (progeny2 =="HDs"){
    
    f1=breeding.diploid(parents,name.cohort ="F1",
                        breeding.size = 1,
                        fixed.breeding=cr1,
                        mutation.rate = 0,    
                        remutation.rate = 0,
                        verbose=F,
                        miraculix.cores = 1) # generation of a unique F1
    
    dh<- breeding.diploid(f1,name.cohort="DH", 
                          breeding.size = c(d,0), # generate only males #mating_plan$nbprogeny[i]
                          dh.mating = TRUE, 
                          same.sex.activ = TRUE, 
                          same.sex.sex = 0,  
                          save.recombination.history=F,
                          verbose=F, 
                          mutation.rate = 0, 
                          remutation.rate = 0,
                          miraculix.cores = 1,
                          randomSeed=num_simulation*i)
    
    geno <- get.geno(dh, cohorts = "DH")
    
  } else if (progeny2 =="RILs"){
    
    
    f1=breeding.diploid(parents, 
                        name.cohort ="F1",
                        breeding.size = c(d,0),
                        repeat.mating = d,  
                        fixed.breeding=cr1,
                        mutation.rate = 0,    
                        remutation.rate = 0,
                        verbose=F,
                        miraculix.cores = 1)
    
    pop=f1
    
    for(generation in 1:selfing){
      
      
      pop=breeding.diploid(pop, breeding.size = c(d,0), 
                           max.offspring = 1, 
                           repeat.mating = 1,  
                           mutation.rate = 0, 
                           remutation.rate = 0,
                           selfing.mating = TRUE, 
                           miraculix.cores = 1,
                           selfing.sex = 0,
                           verbose=F,
                           randomSeed=num_simulation*i*generation)
      
    }
    
    geno <- get.geno(pop, gen=selfing+2)
    
    
  }
  
  
  
  if( i == 1){
    
    progeny_genotypes <- geno
    #progeny_haplotypes <- get.haplo(dh, cohorts = "DH")
    
  } else {
    
    progeny_genotypes <- cbind(progeny_genotypes, geno)
    #progeny_haplotypes <- cbind(progeny_haplotypes, get.haplo(dh, cohorts = "DH"))
    
    
  }
  
  
  
  # progeny_haplotypes <- get.haplo(dh, cohorts = "DH")  %>%
  #   t() %>%
  #   as.data.frame() %>%
  #   mutate(ID=sort(paste0(progeny_names, rep(c(1,2), mating_plan$nbprogeny[i]))))
  
  
  
  
  
}


#initial <- ((generation -1)*nb_run_generation+(rr-1))*D +1

D <- sum(mating_plan$nbprogeny)

progeny_names = paste0("progeny_",gsub("\\s", "0", format(1:D, width=max(nchar(liste_lines)) - nchar("progeny") -1)))
P1=as.vector(unlist(sapply(1:nrow(mating_plan), function(x) rep(mating_plan$P1[x], times= mating_plan$nbprogeny[x] ))))
P2=as.vector(unlist(sapply(1:nrow(mating_plan), function(x) rep(mating_plan$P2[x], times= mating_plan$nbprogeny[x] ))))


pedigree <- data.frame(ID=progeny_names, 
                       P1=P1,
                       P2=P2) %>%
  inner_join(mating_plan %>% dplyr::select(-one_of("nbprogeny")), by=c("P1","P2")) %>%
  mutate(num_simulation=!!num_simulation) %>%
  mutate(value=NA) %>%
  arrange(ID) %>%
  dplyr::select(ID, P1, P2, genetic_map, simulation, qtls, qtls_info, heritability, genomic, population, progeny, population_ID, CONSTRAINTS, criterion, num_simulation, value)






progeny_genotypes <- t(progeny_genotypes) %>%
  as.data.frame() %>%
  mutate(ID=!!progeny_names) %>%
  mutate(P1=!!mating_plan$P1[1], P2=!!mating_plan$P2[1]) %>%
  inner_join(mating_plan %>% dplyr::select(-one_of("nbprogeny")), by=c("P1", "P2")) %>%
  mutate(num_simulation=!!num_simulation) %>%
  arrange(ID) %>%
  dplyr::select(ID, genetic_map, simulation, qtls, qtls_info, heritability, genomic, population, progeny, population_ID, CONSTRAINTS, criterion, num_simulation, one_of(genetic_map$marker))




cat("\n\n OUPUT : genotyping data \n\n")
progeny_genotypes%>% select(1:15) %>% head() 
progeny_genotypes %>% select(1:15) %>% tail() 
dim(progeny_genotypes)
write_delim(progeny_genotypes, titre_genotypes_output, delim = "\t", na = "NA", append = F,  col_names = T, quote_escape = "none")


cat("\n\n OUPUT : pedigree \n\n")
head(pedigree)
tail(pedigree)
dim(pedigree)
write_delim(pedigree, titre_pedigree_output, delim = "\t", na = "NA", append = F,  col_names = T, quote_escape = "none")


sessionInfo()