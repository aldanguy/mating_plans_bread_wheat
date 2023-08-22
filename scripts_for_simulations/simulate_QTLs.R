

Sys.time()
cat("\n\nsimulate_QTLs.R\n\n")
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



titre_markers_input <- variables[1]
titre_genotyping_input <- variables[2]
titre_lines_input <- variables[3]
qtls <- variables[4]
population_ID <- as.numeric(variables[5])
titre_QTLs_output <- variables[6]
titre_TBV_output <- variables[7]



# titre_markers_input <-  "/work/adanguy/these/croisements/110222/results/markers_WE.txt"                                                                                       
# titre_genotyping_input <- "/work/adanguy/these/croisements/110222/results/genotypes_real_data.txt"                                                                              
# titre_lines_input <- "/work/adanguy/these/croisements/110222/results/GEBV_real_data.txt"                                                                                   
# qtls <-  "300rand"                                                                                                                                             
# population_ID <-  "1"                                                                                                                                                   
# titre_QTLs_output <-"/work2/genphyse/dynagen/adanguy/croisements/110222/article/markers/markers_QTLs_sTRUE_iESTIMATED_q300rand_h0.4_gGBLUP_punselected_n1_mWE.txt"        
# titre_TBV_output <- "/work2/genphyse/dynagen/adanguy/croisements/110222/article/parents/TBV_first_generation_sTRUE_iESTIMATED_q300rand_h0.4_gGBLUP_punselected_n1_mWE.txt"
# 


set.seed(population_ID)



simulate_QTL <- function(qtls, variance_TBV, g, m){
  
  
  
  maf <- as.vector(unlist(apply(g %>% dplyr::select(starts_with("AX")), 2, function(x) 2*length(which(x==2)) + length(which(x==1)))))/(2*nrow(g))
  maf <- sapply(maf, function(x) min(x, 1-x))
  
 
  
  
  if (qtls =="all"){
    
    m_subset <- m 
    
  } else if (grepl("mb", qtls)) {
    
    mb <- as.numeric(gsub("mb","", qtls))
    
    
    m_subset <- m %>%
      mutate(maf=!!maf) %>%
      mutate(pos=pos/1e6) %>%
      mutate(segment=plyr::round_any(pos, mb))%>%
      group_by(chr, segment) %>%
      slice(n=sample(1:n(), size=1, replace=F)) %>%
      ungroup() 
    
    
  } else if (grepl("rand", qtls)) {
    
    
    nrandom <- as.numeric(gsub("rand","", qtls))
    
    m_subset <- m %>%
      mutate(maf=!!maf) %>%
      filter(maf >=0.1) %>%
      slice(sample(1:n(),size=nrandom, replace = F ))
    
    
    
  } else if (grepl("cm",qtls)) {
    
    cM <- as.numeric(gsub("cm","", qtls))
    
    
    
    m_subset <- m %>%
      mutate(maf=!!maf) %>%
      filter(maf >=0.1) %>%
      mutate(segment=plyr::round_any(dcum, cM)) %>%
      group_by(chr, segment) %>%
      slice(n=sample(1:n(), size=1, replace=F)) %>%
      ungroup() 
    
  }
  
  markers_to_keep <- m_subset$marker
  
  
  simulated_QTL <- rnorm(n=length(markers_to_keep), m=0, sd=1)
  
  g2 <- g %>% dplyr::select(one_of(markers_to_keep))
  
  var_obs <- var(crossprod(t(g2), as.matrix(simulated_QTL)))
  
  lambda=sqrt(variance_TBV/var_obs)
  
  simulated_QTL2 <- simulated_QTL*c(lambda)
  
  

  
  m_output <- m_subset %>% 
    mutate(simulated_QTLs_effects=!!simulated_QTL2) %>%
    dplyr::select(marker, simulated_QTLs_effects)%>%
    full_join(m, by="marker") %>%
    dplyr::select(chr, region, dcum, marker, simulated_QTLs_effects) %>%
    rowwise() %>%
    mutate(simulated_QTLs_effects=ifelse(is.na(simulated_QTLs_effects),0,simulated_QTLs_effects)) %>%
    arrange(chr, dcum)
  
  
  
  return(m_output$simulated_QTLs_effects)
  
}

cat("\n\n INPUT : markers info \n\n")
m <- fread(titre_markers_input)  %>%  arrange(chr, dcum, marker) 
head(m)
tail(m)
dim(m)

cat("\n\n INPUT : lines info \n\n")
l <- fread(titre_lines_input) 
head(l)
tail(l)
dim(l)


cat("\n\n INPUT : genotyping data \n\n")
g = fread(titre_genotyping_input) %>% arrange(ID)
g %>% select(1:10) %>% head()
g%>% select(1:10) %>% tail()
dim(g)


GEBV <- l %>%
  dplyr::select(value) %>%
  unlist() %>%
  as.vector() 

variance_TBV=round(var(GEBV, na.rm = T))
print(variance_TBV)


#rm(haplo_1, haplo_2)


ID <- l %>%
  arrange(ID) %>%
  dplyr::select(ID) %>%
  unlist() %>%
  as.vector()



QTLs_effects = simulate_QTL(variance_TBV=variance_TBV, qtls=qtls, g=g, m =m)

QTLs_effects2 <- cbind(m, value=QTLs_effects) %>%
  mutate(simulation=TRUE) %>%
  mutate(qtls=!!qtls) %>%
  mutate(qtls_info=TRUE) %>%
  mutate(genomic=NA) %>%
  mutate(population_ID=!!population_ID) %>%
  arrange(chr, marker, dcum)
                

cat("\n\n nb qtls \n\n") 
length(which(QTLs_effects !=0))
  

TBV=crossprod(t(g %>% dplyr::select(starts_with("AX"))), as.matrix(QTLs_effects))
mean(TBV)



TBV <- data.frame(ID=ID,
                  value=TBV) %>%
  arrange(ID) %>%
  mutate(info="TBV") %>%
  mutate(simulation=TRUE) %>%
  mutate(qtls=!!qtls) %>%
  mutate(qtls_info=TRUE) %>%
  mutate(heritability=1) %>%
  mutate(population_ID=!!population_ID) %>%
  mutate(population="unselected") %>%
  dplyr::select(ID, value, info, simulation, qtls, qtls_info, heritability, population, population_ID)







cat("\n\n OUPUT : markers info \n\n")
head(QTLs_effects2)
tail(QTLs_effects2)
dim(QTLs_effects2)

 write.table(QTLs_effects2, titre_QTLs_output, col.names = T, row.names = F, dec=".", sep="\t", quote=F)
  




cat("\n\n OUPUT : real TBV info \n\n")
head(TBV)
tail(TBV)
dim(TBV)
write.table(TBV, titre_TBV_output, col.names = T, row.names = F, dec=".", sep="\t", quote=F)

sessionInfo()