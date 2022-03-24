

Sys.time()
cat("\n\nOHV.R\n\n")
rm(list = ls())
graphics.off()
set.seed(1)

suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(compiler))
suppressPackageStartupMessages(library(parallel))


variables <- commandArgs(trailingOnly=TRUE)
cat("\n\nVariables : \n")
print(variables)
cat("\n\n")



titre_genotypes_parents_input <- variables[1]
titre_markers_value_input <- variables[2]
titre_crosses_input <- variables[3]
titre_function_calcul_index_variance_crosses <- variables[4]
titre_crosses_output <- variables[5]

 
 # titre_genotyping <- "/work2/genphyse/dynagen/adanguy/croisements/190821/value_crosses/lines/haplotypes_selected_simTRUE_300rand_r1.txt"      
 # titre_markers <-  "/work2/genphyse/dynagen/adanguy/croisements/190821/value_crosses/markers/markers_qtls_simTRUE_300rand_r1_WE.txt"        
 # titre_function_calcul_index_variance_crosses <- "/work/adanguy/these/croisements/scripts/03_03_01_01_02_calcul_index_variance_crosses.R"                                 
 # titre_crosses <- "/work2/genphyse/dynagen/adanguy/croisements/190821/value_crosses/crosses/crosses_simTRUE_300rand_r1_selected_gNA_WE.txt"
 # titre_output <-  "/work2/genphyse/dynagen/adanguy/croisements/190821/value_crosses/crosses/crosses_simTRUE_300rand_r1_selected_gNA_WE.txt"
 # selected <-  "selected"  




cat ("\n\n crosses info \n\n")
crosses <- fread(titre_crosses_input)
head(crosses)
tail(crosses)
dim(crosses)
d1 <- dim(crosses)
crosses <- crosses %>% arrange(P1, P2)



cat ("\n\n markers info \n\n")
markers <- fread(titre_markers_value_input)
head(markers)
tail(markers)
dim(markers)


cat ("\n\n genotypes \n\n")
genotyping <- fread(titre_genotypes_parents_input)
genotyping %>% dplyr::select(1:10) %>% head()
genotyping %>% dplyr::select(1:10) %>% tail()
dim(genotyping)
genotyping <- genotyping %>% arrange(ID)





source(titre_function_calcul_index_variance_crosses)

markers <- markers %>%
  arrange(chr, dcum) %>%
  filter(value !=0) %>%
  mutate(desirable=ifelse(value>0, T, F)) 



  

  genotyping <- genotyping %>%
    dplyr::select(ID, one_of(markers$marker))%>%
    arrange(ID)
  

liste_lines <- genotyping$ID



liste_lines_order <- data.frame(ID=liste_lines, order=1:length(liste_lines))


# # change genotyping matrix to have the dosage in unit of desirable allele
# desirable_alternativ_alleles <- markers %>% filter(desirable==T) %>% dplyr::select(marker) %>% unlist() %>% as.vector()
# 
# desirable_alternativ <- genotyping %>% dplyr::select(one_of(desirable_alternativ_alleles))
# desirable_dominant <- genotyping %>% dplyr::select(one_of(markers$marker)) %>% dplyr::select(-one_of(desirable_alternativ_alleles))
# desirable_dominant[desirable_dominant==2] <- 10
# desirable_dominant[desirable_dominant==0] <- 2
# desirable_dominant[desirable_dominant==10] <- 0
# 
# 
# new_genotyping <- cbind(desirable_alternativ, desirable_dominant)

nind=length(liste_lines)


lines_to_keep <- calcul1(nind)

suppressWarnings(crosses_names <-  expand.grid(unlist(liste_lines[1:nind]),
                                               unlist(liste_lines[1:nind])) %>%
                   rename(P.x=Var1, P.y=Var2) %>%
                   inner_join(liste_lines_order, by=c("P.x"="ID"))%>%
                   rename(order.x=order) %>%
                   inner_join(liste_lines_order, by=c("P.y"="ID")) %>%
                   rename(order.y=order) %>%
                   mutate(P1=ifelse(order.x <= order.y, as.character(P.x), as.character(P.y))) %>%
                   mutate(P2=ifelse(order.y <= order.x, as.character(P.x), as.character(P.y))) %>%
                   dplyr::select(P1,P2) %>%
                   slice(lines_to_keep))




ohv <- data.frame()
regions=c("R1","R2a")
chr="1A"
for (chr in unique(markers$chr)){
  
  for (bloc in 1:3){
    
    if (bloc==1){
      
      regions <- c("R1")
    }else if (bloc==2){
      
      regions <- c("R2a", "C", "R2b")
    } else if (bloc==3){
      
      regions <- c("R3")
    }
  


m2 <- markers %>%
  filter(region%in% !!regions) %>%
  filter(chr==!!chr) %>%
  dplyr::select(marker) %>%
  unlist() %>%
  as.vector()

if (length(m2)>0){

e2 <-  markers %>%
  filter(region%in% !!regions) %>%
  filter(chr==!!chr) %>%
  dplyr::select(value) %>%
  unlist() %>%
  as.matrix()



value_for_bloc <- data.frame(P=genotyping$ID, ohv=tcrossprod(genotyping %>% dplyr::select(one_of(m2)) %>% as.matrix(),t(e2)))

delta <- matrix(outer(value_for_bloc$ohv, value_for_bloc$ohv, "-"), ncol=1)
delta <- delta[lines_to_keep]




ohv <- rbind(ohv, cbind(crosses_names, delta) %>%
  mutate(P=ifelse(delta >= 0, P2, P1)) %>%
    mutate(bloc=paste0(chr, regions[1])) %>%
  inner_join(value_for_bloc, by="P") %>%
  dplyr::select(P1, P2, ohv)) %>%
  group_by(P1, P2) %>%
  summarise(ohv=sum(ohv)) %>%
  ungroup() 




  }
}
}
# 
# for (i in 1:(nind-1)){
# 
#   geno <- as.vector(unlist(new_genotyping[i,]))
#   value <- abs(markers$value)
#   OHV_temp <- unlist(mclapply((i+1):nind, function(x) 2*sum(sapply(abs(geno-as.vector(unlist(new_genotyping[x,]))), function(y) ifelse(y ==2, 0, 1))*value) , mc.cores=1))
#   OHV <- c(OHV, OHV_temp)
#   
# }
# dim(OHV)
# length(OHV)
# 
# lines_to_keep <- calcul1(nind)
# dim(lines_to_keep)
# length(lines_to_keep)
# 
# suppressWarnings(crosses_names <-  expand.grid(unlist(liste_lines[1:nind]),
#                                                unlist(liste_lines[1:nind])) %>%
#                    rename(P.x=Var1, P.y=Var2) %>%
#                    inner_join(data.frame(ID=liste_lines) %>%
#                                 
#                                 mutate(ordre.x=1:n()), by=c("P.x"="ID"))%>%
#                    inner_join(data.frame(ID=liste_lines) %>%
#                                 
#                                 mutate(ordre.y=1:n()), by=c("P.y"="ID")) %>%
#                    mutate(P1=ifelse(ordre.x < ordre.y, as.character(P.x), as.character(P.y))) %>%
#                    mutate(P2=ifelse(ordre.y < ordre.x, as.character(P.x), as.character(P.y))) %>%
#                    dplyr::select(P1,P2) %>%
#                    slice(lines_to_keep))
ohv <- ohv %>%
  inner_join(liste_lines_order, by=c("P1"="ID")) %>%
  rename(order.x=order) %>%
  inner_join(liste_lines_order, by=c("P2"="ID")) %>%
  rename(order.y=order) %>%
  mutate(Pa=ifelse(order.x <= order.y, as.character(P1), as.character(P2))) %>%
  mutate( Pb=ifelse(order.x >= order.y, as.character(P1), as.character(P2))) %>%
  dplyr::select(-P1, -P2, -order.x, -order.y) %>%
  rename(P1=Pa, P2=Pb) %>%
  dplyr::select(P1, P2, ohv) %>%
  na.omit()

output1 <- crosses %>% inner_join(ohv, by=c("P1","P2")) %>%
  arrange(P1, P2) 
output2 <- crosses %>% inner_join(ohv, by=c("P1"="P2","P2"="P1")) %>%
  arrange(P1, P2) 

dim(output2)

output <- rbind(output1, output2) %>% 
  rename(OHV=ohv) %>%
  mutate(OHV=2*OHV) %>%
  dplyr::select(P1, P2, genetic_map, simulation, qtls, qtls_info, heritability, genomic, population, progeny, population_ID, CONSTRAINTS, sd, PM, UC1, UC2, PROBA, EMBV, OHV) %>%
  arrange(P1, P2)

cat("\n\n output \n\n")
head(output)
tail(output)
d2 <- dim(output)
d2
write.table(output, titre_crosses_output, col.names = T, row.names = F, dec=".", sep="\t", quote=F)



if (! identical(d1,d2)){
  
  cat ("\n\n probleme size of file \n\n")
}


sessionInfo()