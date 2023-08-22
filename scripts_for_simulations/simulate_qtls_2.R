

Sys.time()
cat("\n\nsimulate_QTL.R\n\n")
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
population <- variables[4]
type <- variables[5]
titre_fonction_simulate_qtls <- variables[6]
titre_markers_output <- variables[7]
titre_lines_output <- variables[8]
# 


# titre_markers_input <-"/work2/genphyse/dynagen/adanguy/croisements/200421/prepare/markers.txt"                                       
# titre_genotyping_input <-"/work2/genphyse/dynagen/adanguy/croisements/200421/prepare/genotyping.txt"                                    
# titre_lines_input <-  "/work2/genphyse/dynagen/adanguy/croisements/200421/value_crosses/lines/lines_gebv_simFALSE_gbasic.txt"        
# population <-  "WE"                                                                                                           
# type <-  "simTRUE_chr_h1.0_r1"                                                                                          
# titre_fonction_simulate_qtls <-  "/work/adanguy/these/croisements/scripts/simulate_qtls_3.R"                                                    
# titre_markers_output <-  "/work2/genphyse/dynagen/adanguy/croisements/200421/value_crosses/markers/markers_real_simTRUE_chr_h1.0_r1.txt"
# titre_lines_output <- "/work2/genphyse/dynagen/adanguy/croisements/200421/value_crosses/lines/lines_simTRUE_chr_h1.0_r1.txt"         
# 
# 

source(titre_fonction_simulate_qtls)

type=gsub("marker","", type)

h <- as.numeric(gsub("h","",as.vector(unlist(strsplit(type, split = "_")))[3]))
qtls=as.vector(unlist(strsplit(type, split = "_")))[2]
r=as.numeric(gsub("r","",as.vector(unlist(strsplit(type, split = "_")))[4]))

set.seed(r)

cat("\n\n INPUT : markers info \n\n")
fread(titre_markers_input) %>% head()
fread(titre_markers_input) %>% tail()
fread(titre_markers_input) %>% dim()


cat("\n\n INPUT : lines info \n\n")
fread(titre_lines_input) %>% head()
fread(titre_lines_input) %>% tail()
fread(titre_lines_input) %>% dim()


cat("\n\n INPUT : genotyping data \n\n")
geno = fread(titre_genotyping_input)
geno %>% select(1:10) %>% head()
geno%>% select(1:10) %>% tail()
dim(geno)


TBV <- fread(titre_lines_input) %>%
  filter(sim==FALSE) %>%
  filter(type=="gebv") %>%
  filter(g=="basic") %>%
  dplyr::select(value) %>%
  unlist() %>%
  as.vector() %>%
  na.omit()

variance_TBV=round(var(TBV, na.rm = T))
print(variance_TBV)



variance_env=((1-h)*variance_TBV)/(h)
print(variance_env)

#rm(haplo_1, haplo_2)


lines2 <- fread(titre_lines_input) %>%
  dplyr::select(-value, -type) %>%
  unique() %>%
  arrange(ID)


genetic_map_raw <- fread(titre_markers_input) %>%
  filter(population==!!population) %>%
  arrange(chr, pos, marker, population) 




snp_effect = simulate_QTL(variance_TBV=variance_TBV, subset=qtls, population=population,geno=geno, genetic_map_raw =genetic_map_raw)

genetic_map <- cbind( fread(titre_markers_input), 
                      value=rep(snp_effect, each=length(fread(titre_markers_input) %>% 
                                                          dplyr:::select(population) %>%
                                                          unique() %>% 
                                                          unlist() %>% 
                                                          as.vector()))) %>%
  mutate(type="real") %>%
  mutate(sim=T) %>%
  mutate(qtls=!!qtls) %>%
  mutate(h=NA) %>%
  mutate(r=paste0("r",r,"r")) %>%
  mutate(g=NA) %>%
  arrange(chr, pos, marker, population, dcum)
                

cat("\n\n nb qtls \n\n") 
length(which(snp_effect !=0))
  

TBV=crossprod(t(fread(titre_genotyping_input)[,-1]), as.matrix(snp_effect))

parental_tbv <- data.frame(ID=fread(titre_genotyping_input)[,1],
                           value=TBV) %>%
  arrange(ID) %>%
  mutate(type="tbv") %>%
  mutate(sim=T) %>%
  mutate(qtls=!!qtls) %>%
  mutate(h=NA) %>%
  mutate(r=paste0("r",r,"r")) %>%
  mutate(g=NA) %>%
  dplyr::select(ID, value, type, sim, qtls, h,r, g)
  


parental_pheno <- data.frame(ID=fread(titre_genotyping_input)[,1],
                             value=TBV + rnorm(length(TBV), m=0, sd=sqrt(variance_env))) %>%
  arrange(ID) %>%
  mutate(type="pheno") %>%
  mutate(sim=T) %>%
  mutate(qtls=!!qtls) %>%
  mutate(h=!!h) %>%
  mutate(r=paste0("r",r,"r")) %>%
  mutate(g=NA) %>%
  dplyr::select(ID, value, type, sim, qtls, h, r, g)




lines <- rbind(parental_tbv, parental_pheno) %>% arrange(ID, type) %>%
  unique()


cat("\n\n OUPUT : markers info \n\n")
head(genetic_map)
tail(genetic_map)
dim(genetic_map)

 write.table(genetic_map, titre_markers_output, col.names = T, row.names = F, dec=".", sep="\t", quote=F)
  




cat("\n\n OUPUT : lines info \n\n")
head(lines)
tail(lines)
dim(lines)
write.table(lines, titre_lines_output, col.names = T, row.names = F, dec=".", sep="\t", quote=F)

sessionInfo()