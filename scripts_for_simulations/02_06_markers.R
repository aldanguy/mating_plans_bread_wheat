


# Goal : markers info (chr, pos)
# Input : physical position
# Output : markers info


# warning : this script should be hidden because of private data


Sys.time()
cat("\n\nmarkers.R\n\n")
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



titre_physical_position_markers_input <- variables[1]
titre_correspondance_chr_input <- variables[2]
titre_chr_regions_input <- variables[3]
titre_genotyping_input <- variables[4]
titre_markers_ouput <- variables[5]

# 
# titre_physical_position_markers <-"/work/adanguy/these/croisements/amont/Vraies_positions_marqueurs.txt"      
# titre_correspondance_chr <- "/work/adanguy/these/croisements/amont/Codes_chr.txt"                       
# titre_chr_regions <-  "/work/adanguy/these/croisements/amont/Decoupage_chr_ble.tab"               
# titre_genotyping_matrix_filtered <-"/work2/genphyse/dynagen/adanguy/croisements/090221/prepare/genotyping_matrix_filtered.txt"
# titre_markers <- "/work2/genphyse/dynagen/adanguy/croisements/090221/prepare/markers_filtered.txt"



cat("\n\n INPUT : info on markers \n\n")
fread(titre_physical_position_markers_input) %>% arrange(chr, pos, BW) %>% head()
fread(titre_physical_position_markers_input) %>% arrange(chr, pos, BW) %>% tail()
fread(titre_physical_position_markers_input) %>% dim()
# warning : contain private data


cat("\n\n INPUT : correspondance of chr ID letters code and number code \n\n")
read.table(titre_correspondance_chr_input, header=F, dec=".", sep="\t")

cat("\n\n INPUT : genomic regions \n\n")
read.table(titre_chr_regions_input, header=T, dec=".", sep="\t", skip=1) 



cat("\n\n INPUT : genotyping data \n\n")
fread(titre_genotyping_input) %>% arrange(ID) %>% select(1:10) %>% slice(1:10)
fread(titre_genotyping_input) %>% arrange(ID) %>% select(1:10) %>% slice((nrow(.)-10) : nrow(.))
fread(titre_genotyping_input) %>% dim()




# A : allocate chr and genomic region to each marker


cor_chr2 <- read.table(titre_correspondance_chr_input, header=F, dec=".", sep="\t") %>%
  rename( chr = V1, chr_code_nombre = V2) %>%
  mutate(chr=as.character(chr))


regions2  <- read.table(titre_chr_regions_input, header=T, dec=".", sep="\t", skip=1)  %>%
  dplyr::select(Chromosome, R1.R2a, R2a.C, C.R2b, R2b.R3) %>%
  mutate(chr = str_remove(Chromosome,"chr")) %>%
  dplyr::select(-one_of("Chromosome")) %>% 
  full_join(cor_chr2, by="chr") %>%
  rename(R1=R1.R2a) %>%
  rename(R2a=R2a.C) %>%
  rename(C=C.R2b) %>%
  rename(R2b=R2b.R3) %>%
  mutate(R3=1e9) %>% # artificial end of R3
  mutate(R1=R1*1e6) %>%
  mutate(R2a=R2a*1e6) %>%
  mutate(C=C*1e6) %>%
  mutate(R2b=R2b*1e6) %>%
  pivot_longer(-c("chr_code_nombre","chr"), names_to ="region", values_to = "pos_max") %>%
  group_by(chr_code_nombre) %>%
  mutate(pos_min=lag(pos_max) +1) %>%
  mutate(pos_min=ifelse(!is.na(pos_min),pos_min,1)) %>%
  mutate(chrregion=paste0(chr,region)) %>%
  mutate(pos=pos_min+((pos_max-pos_min)/2)) %>%
  ungroup() %>%
  dplyr::select(chr, region, pos_min, pos_max)




# B : extraction of marker ID and physical positions

markers <- fread(titre_genotyping_input) %>% 
  colnames() %>%
  str_replace_all(pattern="AX.",replacement="AX-") %>% 
  as.data.frame() %>%
  rename(marker=".") %>%
  mutate(marker=as.character(marker)) %>%
  inner_join(fread(titre_physical_position_markers_input), by=c("marker"="BW")) %>%  # obtain the physical position of markers
  na.omit() %>% # removing every marker with missing info
  group_by(chr, chr2,pos) %>%
  mutate(duplicate=n()) %>%
  filter(duplicate == 1)  %>% # remove markers whose physical position is shared with another marker 
  ungroup() %>%
  inner_join(regions2, by="chr") %>%
  filter(pos >= pos_min & pos <= pos_max) %>%
  arrange(chr, pos, marker) %>%
  dplyr::select(chr, region, pos, marker)  %>%
  as.data.frame()

cat("\n\n markers removed because problems in position, too much NA, too muche heterozygotie \n\n ")
length(which(! fread(titre_genotyping_input) %>% 
               colnames() %in% markers$marker)[-1])


cat("\n\n OUTPUT : markers info \n\n")
head(markers)
tail(markers)
dim(markers)
write.table(markers, titre_markers_ouput, col.names = T, row.names = F, quote=F, dec=".", sep="\t")



sessionInfo()