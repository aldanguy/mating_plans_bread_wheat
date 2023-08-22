

# Goal : simulate progeny genotypes
# Input : genotypes of inbred parental lines and number of progenies per cross
# Output : genotypes of progenies


# To install MOBPS
# install.packages("miraculix", configure.args="CXX_FLAGS=-march=native")



Sys.time()
cat("\n\nprogenies.R\n\n")
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
titre_best_crosses_input <- variables[2]
titre_haplo_input <- variables[3]
titre_function_sort_genotyping_matrix <- variables[4]
titre_genotypes_blupf90_output <- variables[5]
titre_genotypes_output <- variables[6] # output
titre_pedigree_output <- variables[7] # output
nbcores <- as.numeric(variables[8])
type <- variables[9]
critere <- variables[10]
programme <- variables[11]
rr <-as.numeric(variables[12])
population_variance <- variables[13]
population_profile <- variables[14]
progeny <- variables[15]


# titre_markers_input <-  "/work2/genphyse/dynagen/adanguy/croisements/200421/value_crosses/markers/markers_estimated_simFALSE_gbasic_WE.txt"                                                    
# titre_best_crosses_input <- "/work2/genphyse/dynagen/adanguy/croisements/200421/sd_predictions/subset_crosses_simFALSE_gbasic_WE_sd_prediction.txt"                                                
# titre_haplo_input <- "/work2/genphyse/dynagen/adanguy/croisements/200421/sd_predictions/simFALSE_gbasic_WE_sd_prediction_WE_RILsF5/haplotypes_simFALSE_gbasic_WE_sd_prediction_WE.txt"      
# titre_function_sort_genotyping_matrix <- "/work/adanguy/these/croisements/scripts/sort_genotyping_matrix.R"                                                                                                     
# titre_genotypes_blupf90_output <- "simFALSEgbasicWEsdpredictionWERILsF5.txt"                                                                                                                             
# titre_genotypes_output <- "/work2/genphyse/dynagen/adanguy/croisements/200421/sd_predictions/simFALSE_gbasic_WE_sd_prediction_WE_RILsF5/genotypes_simFALSE_gbasic_WE_sd_prediction_WE_RILsF5.txt"
# titre_pedigree_output <-  "/work2/genphyse/dynagen/adanguy/croisements/200421/sd_predictions/simFALSE_gbasic_WE_sd_prediction_WE_RILsF5/pedigree_simFALSE_gbasic_WE_sd_prediction_WE_RILsF5.txt" 
# nbcores <- 2                                                                                                                                                                   
# type <-"simFALSE_gbasic"                                                                                                                                                      
# critere <- "sd_prediction"                                                                                                                                                        
# programme <-  "NA"                                                                                                                                                                   
# rr <-1                                                                                                                                                                    
# population_variance <-"WE"                                                                                                                                                                   
# population_profile <-  "WE"                                                                                                                                                                   
# progeny <-  "RILsF5" 





cat("\n\n INPUT : markers info \n\n ")
genetic_map <- fread(titre_markers_input)
head(genetic_map)
tail(genetic_map)
dim(genetic_map)


cat("\n\n INPUT : best crosses \n\n ")
fread(titre_best_crosses_input) %>% head()
fread(titre_best_crosses_input) %>% tail()
fread(titre_best_crosses_input) %>% dim()
best_crosses <- fread(titre_best_crosses_input) %>%
  filter(nbprogeny>0) 



cat("\n\n INPUT : genotyping \n\n")
haplotypes <- fread(titre_haplo_input)
haplotypes %>% select(1:10) %>% slice(1:10)
haplotypes %>% select(1:10) %>% slice((nrow(.)-10):nrow(.))
haplotypes %>% dim()



set.seed(rr)
source(titre_function_sort_genotyping_matrix)










sim=gsub("sim","",as.vector(unlist(strsplit(type, split="_")))[1])


if (sim == "FALSE"){
  
  g=gsub("g","",as.vector(unlist(strsplit(type, split="_")))[2])
  h=NA
  r=NA
  qtls=NA
  
  etat="estimated"
  
  
  
} else if (sim=="TRUE") {
  
  
  if (grepl("_h", type)){
    
    qtls=as.vector(unlist(strsplit(type, split="_")))[2]
    h=gsub("h","",as.vector(unlist(strsplit(type, split="_")))[3])
    r=paste0(as.vector(unlist(strsplit(type, split="_")))[4],"r")
    g=gsub("g","",as.vector(unlist(strsplit(type, split="_")))[5])
    etat="estimated"
    
    
    
    
  } else if (!grepl("_h", type)) {
    
    qtls=as.vector(unlist(strsplit(type, split="_")))[2]
    r=paste0(as.vector(unlist(strsplit(type, split="_")))[3],"r")
    h=NA
    g=NA
    etat="real"
    
    
    
  }
  
  
}

selfing=as.numeric(as.vector(unlist(strsplit(split="F", progeny)))[2])
progeny2=as.vector(unlist(strsplit(split="F", progeny)))[1]



liste_lines <- best_crosses %>%
  arrange(P1, P2) %>%
  dplyr::select(P1, P2) %>% unlist() %>% as.vector() %>% unique() %>% sort()



genetic_map <- genetic_map %>%
  arrange(chr, pos, marker, population) %>%
  mutate(dcum=dcum/1e2) %>%
  mutate(chr2=as.numeric(as.factor(chr)))




haplotypes <- haplotypes %>%
  filter(ID %in% liste_lines) %>%
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
                              column_to_rownames("haplo") %>%
                              dplyr::select(-ID) %>%
                              t()    , 
                            sex.quota = F, # all individiuals are considered as males
                            snp.name=genetic_map$marker, 
                            chr.nr=genetic_map$chr2, 
                            bp=genetic_map$pos, 
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
for ( i in 1:nrow(best_crosses)){
  
  #print(i)
  
  
  print(i)
  
  
  
  
  parent1 = which(liste_lines2 %in% best_crosses$P1[i]) # ID of P1
  parent2 = which(liste_lines2 %in% best_crosses$P2[i]) # ID of P2
  d=floor(best_crosses$nbprogeny[i])
  
  cr1=matrix(c(gen1,sex1,parent1,gen2,sex1,parent2,sex.probability),nrow=1,byrow=T) # indicate to MOPBS which parental lines to cross
  
  if (progeny2 =="HDs"){
  
  f1=breeding.diploid(parents,name.cohort ="F1",
                      breeding.size = 1,
                      fixed.breeding=cr1,
                      mutation.rate = 0,    
                      remutation.rate = 0,
                      verbose=F,
                      miraculix.cores = nbcores) # generation of a unique F1
  
  dh<- breeding.diploid(f1,name.cohort="DH", 
                        breeding.size = c(d,0), # generate only males #best_crosses$nbprogeny[i]
                        dh.mating = TRUE, 
                        same.sex.activ = TRUE, 
                        same.sex.sex = 0,  
                        save.recombination.history=F,
                        verbose=F, 
                        mutation.rate = 0, 
                        remutation.rate = 0,
                        miraculix.cores = nbcores,
                        randomSeed=rr*i)
  
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
                      miraculix.cores = nbcores)
  
  pop=f1
  
  for(generation in 1:selfing){
    
    pop=breeding.diploid(pop, breeding.size = c(d,0), 
                         max.offspring = 1, 
                         repeat.mating = 1,  
                         mutation.rate = 0, 
                         remutation.rate = 0,
                         selfing.mating = TRUE, 
                         miraculix.cores = nbcores,
                         selfing.sex = 0,
                         verbose=F,
                         randomSeed=rr*i*generation)
    
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
  #   mutate(ID=sort(paste0(progeny_names, rep(c(1,2), best_crosses$nbprogeny[i]))))
  
  
  
  
  
}


#initial <- ((generation -1)*nb_run_generation+(rr-1))*D +1

D <- sum(best_crosses$nbprogeny)

progeny_names = paste0("progeny_",gsub("\\s", "0", format(1:D, width=max(nchar(liste_lines)) - nchar("progeny") -1)))
P1=as.vector(unlist(sapply(1:nrow(best_crosses), function(x) rep(best_crosses$P1[x], times= best_crosses$nbprogeny[x] ))))
P2=as.vector(unlist(sapply(1:nrow(best_crosses), function(x) rep(best_crosses$P2[x], times= best_crosses$nbprogeny[x] ))))

pedigree <- data.frame(ID=progeny_names, 
                       P1=P1,
                       P2=P2) %>%
  mutate(etat=!!etat,
         qtls=!!qtls,
         sim=!!sim,
         h=!!h,
         r=!!r,
         rr=!!rr,
         critere=!!critere,
         programme=!!programme,
         population_variance=!!population_variance,
         population_profile=!!population_profile,
         progeny=!!progeny)





progeny_genotypes <- t(progeny_genotypes) %>% 
  as.data.frame() %>%
  mutate(ID=!!progeny_names) %>%
  mutate(type=!!etat) %>%
  mutate(sim=!!sim) %>%
  mutate(qtls=!!qtls) %>%
  mutate(h=!!h) %>%
  mutate(r=!!r) %>%
  mutate(rr=!!rr) %>%
  mutate(g=!!g) %>%
  mutate(population_variance=!!population_variance) %>%
  mutate(population_profile=!!population_profile) %>%
  mutate(critere=!!critere) %>% 
  mutate(programme=!!programme) %>%
  mutate(progeny=!!progeny) %>%
  dplyr::select(ID, type, sim, qtls, h, r, critere, programme, population_variance, population_profile, progeny,everything()) %>%
  arrange(ID) %>%
  as.data.frame()



# 
# progeny_haplotypes <- t(progeny_haplotypes) %>% 
#   as.data.frame() %>%
#   mutate(ID=paste0(rep(progeny_names, each=2),"_haplo", 1:2)) %>%
#   mutate(run=run) %>%
#   dplyr::select(ID, run, starts_with("AX")) %>%
#   as.data.frame()
# 
# progeny_haplotypes <- sort_genotyping_matrix(progeny_haplotypes, genetic_map)


if ((grepl("TRUE", type) & grepl("_h", type)) | grepl("FALSE", type)){
  

  progeny_genotypes_bluf90 <-  sort_genotyping_matrix(progeny_genotypes, genetic_map) %>%
    dplyr::select(ID, starts_with(c("AX","rs"))) %>%
    unite(SNP, starts_with(c("AX","rs")), sep="")%>%
    dplyr::select(ID, SNP) %>%
    as.data.frame()
  
  cat("\n\n OUPUT : genotyping data for BLUPF90 \n\n")
  print(dim(progeny_genotypes_bluf90))
  print(nchar(progeny_genotypes_bluf90[1,2]))
  write_delim(progeny_genotypes_bluf90, titre_genotypes_blupf90_output, delim = " ", na = "NA", append = F,  col_names = F, quote_escape = "none")
  
  
} 


cat("\n\n OUPUT : genotyping data \n\n")
progeny_genotypes%>% select(1:10) %>% head() %>% print()
progeny_genotypes %>% select(1:10) %>% tail() %>% print()
progeny_genotypes %>% dim() %>% print()
write_delim(progeny_genotypes, titre_genotypes_output, delim = "\t", na = "NA", append = F,  col_names = T, quote_escape = "none")



cat("\n\n OUPUT : pedigree \n\n")
head(pedigree)
tail(pedigree)
dim(pedigree)
write_delim(pedigree, titre_pedigree_output, delim = "\t", na = "NA", append = F,  col_names = T, quote_escape = "none")



tf <- Sys.time()
tf-t1

sessionInfo()