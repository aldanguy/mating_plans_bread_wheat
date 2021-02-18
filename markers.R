


# Goal : prepare markers info
# Input : physical position
# Output : markers with physical position


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



titre_physical_position_markers <- variables[1]
titre_correspondance_chr <- variables[2]
titre_chr_regions <- variables[3]
titre_genotyping_matrix_filtered <- variables[4]
titre_markers <- variables[5]

# 
# titre_physical_position_markers <-"/work/adanguy/these/croisements/amont/Vraies_positions_marqueurs.txt"      
# titre_correspondance_chr <- "/work/adanguy/these/croisements/amont/Codes_chr.txt"                       
# titre_chr_regions <-  "/work/adanguy/these/croisements/amont/Decoupage_chr_ble.tab"               
# titre_genotyping_matrix_filtered <-"/work2/genphyse/dynagen/adanguy/croisements/090221/prepare/genotyping_matrix_filtered.txt"
# titre_markers <- "/work2/genphyse/dynagen/adanguy/croisements/090221/prepare/markers_filtered.txt"



cat("\n\n INPUT : physical positions of markers \n\n")
pos <- fread(titre_physical_position_markers)
head(pos)
dim(pos)
# warning : contain private data
# column 1 = BW = marker ID (string, as many levels as number of markers, here 423 385)
# column 2 = chr = chr ID with letters (string, 21 levels)
# column 3 = chr2 = chr ID with numbers (intergers, 21 levels)
# column 4 = pos = physical position of marker (intergers, units bp)
# to check that chr ID are consistent : table(pos$chr, pos$chr2)
# dimension of file : 423 385 * 4

cat("\n\n INPUT : correspondance of chr letters and number code ID \n\n")
cor_chr <- read.table(titre_correspondance_chr, header=F, dec=".", sep="\t")
cor_chr
# column 1 = V1 = chr = chr ID with letters (string, 21 levels)
# column 2 = V2 = chr ID with numbers (intergers, 21 levels)
# to check that chr ID are consistent : table(pos$chr, pos$chr2) should match cor_chr

# dimension of file : 21 * 2

cat("\n\n INPUT : chromosome partionning \n\n")
regions  <- read.table(titre_chr_regions, header=T, dec=".", sep="\t", skip=1) 
regions
# column 1 = Chromosome = "chr" + chr ID with letters (string, 21 levels)
# column 3 = R1.R2a = physical frontier between regions R1 and R2a (intergers, units Mb)
# column 4 = R2a.C = physical frontier between regions R2a and C (intergers, units Mb)
# column 5 = C.R2b = physical frontier between regions C and R2b (intergers, units Mb)
# column 6 = R2b.R3 = physical frontier between regions R2b and R3 (intergers, units Mb)
# column 2 and 7 - 16 = no importance here
# dimension of file : 21*16



cat("\n\n INPUT : genotyping matrix to have markers ID \n\n")
genotyping <- suppressWarnings(fread(titre_genotyping_matrix_filtered))
genotyping[1:10, 1:10]
dim(genotyping)
# column 1 = V1 = variery ID (string, as many levels as the row number, here 2 143)
# column 2 - 31 315 = AX.1234567 = marker ID (intergers), here 31 315 markers
# dimension of file : 2 143 * 31315



# markers used 
genotyping_matrix <- scan(titre_genotyping_matrix_filtered, nline=1, what="character")


# A : allocate chr and genomic region to each marker


cat("\n\n corresponding ID for chr \n\n")
cor_chr2 <- cor_chr %>%
  rename( chr = V1, chr_code_nombre = V2) %>%
  mutate(chr=as.character(chr))
head(cor_chr2)


regions2  <- regions %>%
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

cat("\n\n frontiers of genomic regions\n\n")
head(regions2)





# B : extraction of marker ID and physical positions

markers <- colnames(genotyping) %>%
  str_replace_all(pattern="AX.",replacement="AX-") %>% 
  as.data.frame() %>%
  rename(marker=".") %>%
  mutate(marker=as.character(marker)) %>%
  inner_join(pos, by=c("marker"="BW")) %>%  # obtain the physical position of markers
  na.omit() %>% # removing every marker with missing info
  group_by(chr, chr2,pos) %>%
  mutate(duplicate=n()) %>%
  filter(duplicate == 1)  %>% # remove markers whose physical position is shared with another marker 
  ungroup() %>%
  arrange(chr, pos) %>%
  inner_join(regions2, by="chr") %>%
  filter(pos >= pos_min & pos <= pos_max) %>%
  arrange(chr, pos) %>%
  filter(marker %in% genotyping_matrix) %>%
  dplyr::select(chr, region, pos, marker) 

cat("\n\n markers removed because problems in position \n\n ")
length(which(!colnames(genotyping) %in% markers$marker)[-1])


cat("\n\n OUTPUT : markers with physical position \n\n")
head(markers)
dim(markers)
# column 1 = chr = chr ID with letters (string, 21 levels)
# column 2 = region = ID of chr region (string, 5 levels R1, R2a, C, R2b, R3)
# column 4 = pos = physical position of marker (intergers, units bp)
# column 5 = marker = marker ID (string, as many levels as number of markers, here 31 314)
# dimension: 31314*4
write.table(markers, titre_markers, col.names = T, row.names = F, quote=F, dec=".", sep="\t")



sessionInfo()