



# Goal : gather data
# Input : blupf90 outputs, gebv and snp effects
# Output : files updated



Sys.time()
cat("\n\nafter_blupf90.R\n\n")
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



titre_gebv_input <- variables[1]
titre_snp_effects_input <- variables[2]
titre_lines_input <- variables[3]
titre_markers_input <- variables[4]
titre_markers_output <- variables[5]
titre_lines_output <- variables[6]
type <- variables[7]


# titre_gebv_input <-  "/work2/genphyse/dynagen/adanguy/croisements/200421/value_crosses/gblup/marker_simTRUE_500rand_h0.4_r6_gbasic/SNP_predictions_marker_simTRUE_500rand_h0.4_r6_gbasic.txt"
# titre_snp_effects_input <- "/work2/genphyse/dynagen/adanguy/croisements/200421/value_crosses/gblup/marker_simTRUE_500rand_h0.4_r6_gbasic/snp_sol_marker_simTRUE_500rand_h0.4_r6_gbasic.txt"        
# titre_lines_input <- "/work2/genphyse/dynagen/adanguy/croisements/200421/prepare/lines.txt"                                                                                                  
# titre_markers_input <-  "/work2/genphyse/dynagen/adanguy/croisements/200421/prepare/markers.txt"                                                                                                
# titre_markers_output <-"/work2/genphyse/dynagen/adanguy/croisements/200421/value_crosses/gblup/marker_simTRUE_500rand_h0.4_r6_gbasic/markers_marker_simTRUE_500rand_h0.4_r6_gbasic.txt"        
# titre_lines_output <-  "/work2/genphyse/dynagen/adanguy/croisements/200421/value_crosses/gblup/marker_simTRUE_500rand_h0.4_r6_gbasic/lines_marker_simTRUE_500rand_h0.4_r6_gbasic.txt"          
# type <-  "marker_simTRUE_500rand_h0.4_r6_gbasic"
#  
cat("\n\n INPUT : gebv \n\n")
fread(titre_gebv_input) %>% head()
fread(titre_gebv_input) %>% tail()
fread(titre_gebv_input) %>% dim()




cat("\n\n INPUT : snp effects \n\n")
fread(titre_snp_effects_input) %>% head()
fread(titre_snp_effects_input) %>% tail()
fread(titre_snp_effects_input) %>% dim()


cat("\n\n INPUT : lines info \n\n")
fread(titre_lines_input) %>% arrange(ID, type) %>% head()
fread(titre_lines_input) %>% arrange(ID, type) %>% tail()
fread(titre_lines_input) %>% arrange(ID, type)  %>% head()
fread(titre_lines_input) %>% dim()



cat("\n\n INPUT : lines info \n\n")
fread(titre_markers_input) %>% head()
fread(titre_markers_input) %>% tail()
fread(titre_markers_input) %>% dim()


type=gsub("marker_","",type)


snp_effects2 <- fread(titre_snp_effects_input) %>%
  rename(chr2=chr) %>%
  rename(value=snp_effect) %>%
  dplyr::select(chr2, pos, value)%>%
  full_join(fread(titre_markers_input)  %>%
              mutate(chr2=as.numeric(as.factor(chr))) , 
            by=c("chr2", "pos")) %>%
  dplyr::select(-chr2)%>%
  mutate(value=ifelse(is.na(value), 0, value)) %>%
  mutate(type="estimated") %>%
  arrange(chr, pos, marker, population)







lines2 <- fread(titre_lines_input)  %>%
  arrange(ID) %>%
  dplyr::select(-one_of("value", "type")) %>%
  inner_join(fread(titre_gebv_input) %>% rename(ID=V1, value=V3) %>% dplyr::select(-V2), by="ID") %>%
  mutate(type="gebv") 





if (length(grep("FALSE", type))==1){
  
  print("simF")
  
  lines2 <- lines2 %>% 
    mutate(sim=FALSE) %>%
    mutate(qtls=NA) %>%
    mutate(h=NA) %>%
    mutate(r=NA) %>%
    mutate(g="basic") %>%
    arrange(ID) %>%
    dplyr::select(ID, value, type, sim, qtls, h, r, g)
  
  
  snp_effects2 <- snp_effects2 %>%
    mutate(sim=FALSE) %>%
    mutate(qtls=NA) %>%
    mutate(h=NA) %>%
    mutate(r=NA) %>%
    mutate(g="basic") %>%
    arrange(chr, pos, marker) %>%
    dplyr::select(chr, region, pos, marker, population, dcum, value, sim, qtls, h, r, g)
  
}else if (length(grep("TRUE", type))==1) {
  
  print("simT")
  

  qtls=as.vector(unlist(strsplit(type, split = "_")))[2]
  h=as.numeric(gsub("h", "", as.vector(unlist(strsplit(type, split = "_")))[3]))
  r=paste0(as.vector(unlist(strsplit(type, split = "_")))[4],"r")
  g=gsub("g","",as.vector(unlist(strsplit(type, split = "_")))[5])
  
  
  
  
  lines2 <- lines2 %>% 
    mutate(sim=TRUE) %>%
    mutate(qtls=!!qtls) %>%
    mutate(h=!!h) %>%
    mutate(r=!!r) %>%
    mutate(g=!!g) %>%
    arrange(ID) %>%
    dplyr::select(ID, value, type, sim, qtls, h, r, g)
  
  
  
  snp_effects2 <- snp_effects2 %>%
    mutate(sim=TRUE) %>%
    mutate(qtls=!!qtls) %>%
    mutate(h=!!h) %>%
    mutate(r=!!r) %>%
    mutate(g=!!g) %>%
    arrange(chr, pos, marker) %>%
    dplyr::select(chr, region, pos, marker, population, dcum, value, sim, qtls, h, r, g)
  
  
} 
         
         
         
    

##########################


cat("\n\n OUTPUT : lines info\n\n")
head(lines2)
tail(lines2)
dim(lines2)
write.table(lines2, titre_lines_output, col.names = T, row.names = F, dec=".", sep="\t", quote=F)




cat("\n\n OUTPUT : markers with markers effects \n\n")
head(snp_effects2)
tail(snp_effects2)
dim(snp_effects2)


write.table(snp_effects2, titre_markers_output, col.names = T, row.names = F, dec=".", sep="\t", quote=F)



sessionInfo()