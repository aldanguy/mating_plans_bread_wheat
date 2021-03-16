

Sys.time()
cat("\n\nafter_qtls_simulations.R\n\n")
rm(list = ls())
graphics.off()
set.seed(1)

suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(compiler))
suppressPackageStartupMessages(library(readr))



variables <- commandArgs(trailingOnly=TRUE)
cat("\n\nVariables : \n")
print(variables)
cat("\n\n")


titre_markers <- variables[1]
titre_lines <- variables[2]


# titre_markers <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/markers_filtered_estimated.txt"
# titre_lines <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/lines_filtered_estimated.txt"
# 
# 
# titre_markers <- "/work2/genphyse/dynagen/adanguy/croisements/150221/value_crosses/markers_filtered_estimated.txt"
# titre_lines <- "/work2/genphyse/dynagen/adanguy/croisements/150221/value_crosses/lines_filtered_estimated.txt"
cat("\n\n input\n\n")

m <- fread(titre_markers)
fread(titre_markers) %>% arrange(chr, pos, marker, type) %>% head()
fread(titre_markers) %>% arrange(chr, pos, marker, type) %>% tail()
fread(titre_markers) %>% dim()
fread(titre_markers) %>% dplyr::select(type) %>% unlist() %>% as.vector() %>% unique() %>% sort()

l <- fread(titre_lines)
fread(titre_lines) %>% arrange(ID, type) %>% head()
fread(titre_lines) %>% arrange(ID, type) %>% tail()
fread(titre_lines) %>% dim()
fread(titre_lines) %>% dplyr::select(type) %>% unlist() %>% as.vector() %>% unique() %>% sort()



extraction <- function(string, character_split, number){
  
  out <- as.vector(unlist(strsplit(string, split=character_split)))
  
  if (number > length(out)){
    
    out <- NA
  } else {
    
    out <- out[number]
  }
  
  return(out)
  
}

l <- fread(titre_lines) %>%
  unique() %>%
  rowwise() %>%
  mutate(type2=extraction(string=type, character_split="_", number=1)) %>%
  mutate(sim=extraction(string=type, character_split="_", number=2))  %>%
  mutate(subset=extraction(string=type, character_split="_", number=3)) %>%
  mutate(h=extraction(string=type, character_split="_", number=4)) %>%
  mutate(r=extraction(string=type, character_split="_", number=5)) %>%
  as.data.frame() %>%
  mutate(type=ifelse(!is.na(r),paste0(type2,"_",sim,"_",subset,"_",h,"_",r), type)) %>%
  mutate(type=ifelse(type2=="tbv", paste0("tbv_",sim,"_",subset,"_",r), type)) %>%
  dplyr::select(-sim, -subset, -h, -r, -type2) %>%
  unique()  %>%
  dplyr::select(-type, everything())%>%
  dplyr::select(-value, everything()) %>%
  arrange(ID, type)



m <- fread(titre_markers) %>% rowwise() %>%
  mutate(sim=extraction(string=type, character_split="_", number=2)) %>%
  mutate(subset=extraction(string=type, character_split="_", number=3)) %>%
  mutate(h=extraction(string=type, character_split="_", number=4)) %>%
  mutate(r=extraction(string=type, character_split="_", number=5)) %>%
  mutate(type=ifelse(!is.na(r) & !is.na(h),paste0("marker_",sim,"_",subset,"_",h,"_",r), type)) %>%
  mutate(type=ifelse(!is.na(r) & is.na(h),paste0("marker_",sim,"_",subset,"_",r), type)) %>%
  as.data.frame() %>%
  dplyr::select(-sim, -subset, -h, -r) %>%
  unique()  %>%
  dplyr::select(-type, everything())%>%
  dplyr::select(-value, everything()) %>%
  arrange(chr, pos, marker, population, type) %>%
  as.data.frame()

cat("\n\n OUTPUT : lines info \n\n")
head(l)
tail(l)
dim(l)
write.table(l, titre_lines, col.names = T, row.names = F, dec=".", sep='\t', quote=F)

cat("\n\n OUTPUT : markers info \n\n")
head(m)
tail(m)
dim(m)
write_delim(m, titre_markers, delim = "\t", na = "NA", append = F,  col_names = T, quote_escape = "none")


sessionInfo()