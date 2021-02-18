

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







titre_markers_filtered_subset_estimated <- variables[1]
titre_best_crosses <- variables[2]
titre_haplotypes_critere <- variables[3] # ouput but input at t>1
D <- as.numeric(variables[4])
generation <- as.numeric(variables[5])
run <- as.numeric(variables[6])
nb_run_generation <- as.numeric(variables[7])
titre_genotypes_blupf90_critere <- variables[8]
titre_genotypes_critere <- variables[9] # output
titre_pedigree_critere <- variables[10] # output
titre_function_sort_genotyping_matrix <- variables[11]
nbcores <- as.numeric(variables[12])
population <- variables[13]
critere <- variables[14]
titre_genotyping_matrix_filtered_imputed_subset <- variables[15] #only useful at t1
titre_pedigree <- variables[16] # only useful at t1



 
  # titre_markers_filtered_subset_estimated <- "/work/adanguy/these/croisements/050221/markers_filtered_subset_estimated.txt"               
  # titre_best_crosses <- "/work/adanguy/these/croisements/050221/sd_predictions/subset_crosses.txt"                   
  # titre_haplotypes_critere <- "/work/adanguy/these/croisements/050221/sd_predictions/haplotypes_sd_predictions_g1_run1.txt"
  # D <- 10000
  # generation <- 1
  # run <- 1                                                                                          
  # nb_run_generation <- 10                                                                                        
  # titre_genotypes_blupf90_critere <- "/work/adanguy/blupf90/snp/sd_predictions_g1_run1.txt"                                       
  # titre_genotypes_critere <-  "/work/adanguy/these/croisements/050221/sd_predictions/genotyping_sd_predictions_g1_run1.txt"
  # titre_pedigree_critere <-"/work/adanguy/these/croisements/050221/sd_predictions/pedigree_sd_predictions_g1_run1.txt"  
  # titre_function_sort_genotyping_matrix <- "/work/adanguy/these/croisements/scripts/sort_genotyping_matrix.R"                           
  # titre_genotyping_matrix_filtered_imputed_subset <- "/work/adanguy/these/croisements/050221/genotyping_matrix_filtered_imputed_subset.txt"       
  # titre_pedigree <-  "/work/adanguy/these/croisements/050221/pedigree.txt"  

start_seed=run*generation
set.seed(start_seed)
source(titre_function_sort_genotyping_matrix)

cat("\n\n INPUT : genetic map \n\n ")
head(fread(titre_markers_filtered_subset_estimated))
# warning : marker order/number should respect marker order/number of genotyping matrix
# column 1 = chr = chromosome letter ID (string, 21 levels)
# column 3 = pos = physical position of marker (pb) (integer)
# column 4 = marker = marker ID (string, as many levels as number of markers)
# column 5 = dcum = cumulated genetic distance on the chromosome (cM) (numeric)
# column 3 = no importance here



cat("\n\n INPUT : best crosses \n\n ")
best_crosses <- fread(titre_best_crosses)
head(best_crosses)



best_crosses <- best_crosses%>%
  filter(nbprogeny>0) %>%
  filter(generation==generation)


if (!is.na(unique(best_crosses$run))){
  
  best_crosses <- best_crosses %>% filter(run==run)
  
}


liste_lines <- best_crosses %>% dplyr::select(P1, P2) %>% unlist() %>% as.vector() %>% unique() %>% sort()




if (generation ==1 & run==1){ # conversion of genotyping matrix into haplotypes matrix 
  

  cat("\n\n INPUT : pedigree \n\n ")
  pedigree <- fread(titre_pedigree) %>%
    arrange(generation, P1, P2) %>%
    mutate(run=NA) %>%
    mutate(best_crosses=NA) %>%
    as.data.frame()
  
  print(head(pedigree))
  
  
  
  
  cat("\n\n INPUT : genotyping matrix of parents \n\n ")
  # warning : no tolerance for missing values
  # column 1 = line2 = modified ID of variety (string, as many levels as number of parents)
  # column 2 - 19751 : genotypes at marker AX-... (as many columns as number of markers +1 ), genotypes = 0 homozygote reference allele, 1, 2 alternativ allele (integer)
  print(fread(titre_genotyping_matrix_filtered_imputed_subset)[1:10,1:10])
  
  genotyping_matrix_parents <- fread(titre_genotyping_matrix_filtered_imputed_subset) %>%
    rename(ID=line2) %>% 
    arrange(ID) %>%
    mutate(run=NA) %>%
    dplyr::select(ID, run, starts_with("AX"))
  
  write_delim(genotyping_matrix_parents, titre_genotypes_critere, delim = "\t", na = "NA", append = F,  col_names = T, quote_escape = "none")
  # save files
  write_delim(pedigree, titre_pedigree_critere, delim = "\t", na = "NA", append = F,  col_names = T, quote_escape = "none")
  rm(genotyping_matrix_parents, pedigree)
  
}

if (generation==1){
  # ID of parental lines
  
  # conversion of parental genotypes to haplotypes
  # input for MOBPS
  # if genotype = 2 -> haplo_1 = 1 and haplo_2 = 2 ; genotype = 1 -> haplo_1=0, haplo_2 = 1 ; genotype = 0, haplo_1=0, haplo_2=0
  haplo_1 <- fread(titre_genotyping_matrix_filtered_imputed_subset) %>% 
    filter(line2 %in% liste_lines) %>%
    arrange(line2) %>%
    rename(ID2=line2)%>%
    mutate(ID=paste0(ID2,"_haplo1")) 
  
  haplo_2 <- fread(titre_genotyping_matrix_filtered_imputed_subset) %>% 
    filter(line2 %in% liste_lines) %>%
    arrange(line2) %>%
    rename(ID2=line2)%>%
    mutate(ID=paste0(ID2,"_haplo2")) %>%
    group_by(ID) %>%
    mutate_at(vars(starts_with("AX")), funs(min(1,.)))  %>% 
    ungroup() 
  
  haplo_2[haplo_1==1] <- 0 # if locus is heterozygote, the sum per locus should be equal to 1
  
  haplotypes <- haplo_1  %>%
    group_by(ID) %>%
    mutate_at(vars(starts_with("AX")), funs(min(1,.))) %>%
    ungroup() %>%
    rbind(.,haplo_2) %>%
    arrange(ID)  %>% 
    mutate(run=run) %>%
    dplyr::select(ID, ID2, run, starts_with("AX")) %>%
    as.data.frame()
  
  rm(haplo_1, haplo_2)
  cat("\n\n OUPUT : haplotypes \n\n ")
  write_delim(haplotypes %>% dplyr::select(-ID2), titre_haplotypes_critere, delim = "\t", na = "NA", append = F,  col_names = T, quote_escape = "none")
  
  
  
} else {
  
  haplotypes <- fread(titre_haplotypes_critere) %>%
    mutate(ID2 = unlist(strsplit(ID, split="_haplo"))[seq(1, nrow(.)*2, 2)]) %>%
    filter(ID2 %in% liste_lines) %>%
    arrange(ID) %>% 
    mutate(run=run) %>%
    dplyr::select(ID, ID2,  run, starts_with("AX")) 
  
  cat("\n\n INPUT : haplotypes \n\n")

  
}









liste_lines2 <- haplotypes %>% #to have order of parents in haplotypes
  dplyr::select(ID2) %>%
  arrange(ID2) %>%
  unlist() %>%
  as.vector() %>%
  unique()


# genetic map
# input for MOBPS




genetic_map <- fread(titre_markers_filtered_subset_estimated) %>%
  arrange(chr, pos) %>%
  mutate(chr2=as.numeric(as.factor(chr))) %>%
  mutate(dcum_WE=dcum_WE/1e2) %>%
  mutate(dcum_EE=dcum_EE/1e2) %>%
  mutate(dcum_WA=dcum_WA/1e2) %>%
  mutate(dcum_EA=dcum_EA/1e2) %>%
  mutate(dcum_CsRe=dcum_CsRe/1e2) # convert to M


colonne_genetic_map <- colnames(genetic_map)[grep(population,colnames(genetic_map))]


parents <- creating.diploid(dataset = haplotypes%>%
                              column_to_rownames("ID") %>%
                              dplyr::select(-ID2, -run) %>%
                              t()    , 
                            sex.quota = F, # all individiuals are considered as males
                            snp.name=genetic_map$marker, 
                            chr.nr=genetic_map$chr2, 
                            bp=genetic_map$pos, 
                            snp.position = genetic_map[,colonne_genetic_map], 
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
progeny_haplotypes <- data.frame()
for ( i in 1:nrow(best_crosses)){
  
  print(i)
  
  
  
  
  
  
  
  parent1 = which(liste_lines2 %in% best_crosses$P1[i]) # ID of P1
  parent2 = which(liste_lines2 %in% best_crosses$P2[i]) # ID of P2
  d=floor(best_crosses$nbprogeny[i])
  
  cr1=matrix(c(gen1,sex1,parent1,gen2,sex1,parent2,sex.probability),nrow=1,byrow=T) # indicate to MOPBS which parental lines to cross
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
                        randomSeed=start_seed*i)
  if( i == 1){
    
    progeny_genotypes <- get.geno(dh, cohorts = "DH")
    progeny_haplotypes <- get.haplo(dh, cohorts = "DH")
    
  } else {
    
    progeny_genotypes <- cbind(progeny_genotypes, get.geno(dh, cohorts = "DH"))
    progeny_haplotypes <- cbind(progeny_haplotypes, get.haplo(dh, cohorts = "DH"))
    
    
  }
  
  
  
  # progeny_haplotypes <- get.haplo(dh, cohorts = "DH")  %>%
  #   t() %>%
  #   as.data.frame() %>%
  #   mutate(ID=sort(paste0(progeny_names, rep(c(1,2), best_crosses$nbprogeny[i]))))
  
  
  
  
  
}



initial <- ((generation -1)*nb_run_generation+(run-1))*D +1
progeny_names = paste0("progeny_",gsub("\\s", "0", format(initial:(initial+sum(best_crosses$nbprogeny) -1), width=max(nchar(liste_lines)) - nchar("progeny") -1)))
P1=as.vector(unlist(sapply(1:nrow(best_crosses), function(x) rep(best_crosses$P1[x], times= best_crosses$nbprogeny[x] ))))
P2=as.vector(unlist(sapply(1:nrow(best_crosses), function(x) rep(best_crosses$P2[x], times= best_crosses$nbprogeny[x] ))))
pedigree <- data.frame(ID=progeny_names, P1=P1, P2=P2, generation=generation, run=run, best_crosses=critere)



progeny_genotypes <- t(progeny_genotypes) %>% 
  as.data.frame() %>%
  mutate(ID=progeny_names) %>%
  mutate(run=run) %>%
  dplyr::select(ID, run, starts_with("AX")) %>%
  as.data.frame()

progeny_genotypes <- sort_genotyping_matrix(progeny_genotypes, genetic_map)


progeny_genotypes_bluf90 <- progeny_genotypes %>%
  unite(SNP, starts_with("AX"), sep="")%>%
  dplyr::select(ID, SNP) %>%
  as.data.frame()



progeny_haplotypes <- t(progeny_haplotypes) %>% 
  as.data.frame() %>%
  mutate(ID=paste0(rep(progeny_names, each=2),"_haplo", 1:2)) %>%
  mutate(run=run) %>%
  dplyr::select(ID, run, starts_with("AX")) %>%
  as.data.frame()

progeny_haplotypes <- sort_genotyping_matrix(progeny_haplotypes, genetic_map)


cat("\n\n OUPUT : genotyping data for BLUPF90 \n\n")
dim(progeny_genotypes_bluf90)
write_delim(progeny_genotypes_bluf90, titre_genotypes_blupf90_critere, delim = " ", na = "NA", append = F,  col_names = F, quote_escape = "none")

cat("\n\n OUPUT : genotyping data \n\n")
progeny_genotypes[1:2,1:10]
dim(progeny_genotypes)
write_delim(progeny_genotypes, titre_genotypes_critere, delim = "\t", na = "NA", append = T,  col_names = F, quote_escape = "none")

cat("\n\n OUPUT : pedigree \n\n")
head(pedigree)
dim(pedigree)
write_delim(pedigree, titre_pedigree_critere, delim = "\t", na = "NA", append = T,  col_names = F, quote_escape = "none")

cat("\n\n OUPUT : haplotypes \n\n")
progeny_haplotypes[1:2,1:10]
dim(progeny_haplotypes)
write_delim(progeny_haplotypes, titre_haplotypes_critere, delim = "\t", na = "NA", append = T,  col_names = F, quote_escape = "none")



tf <- Sys.time()
tf-t1

sessionInfo()