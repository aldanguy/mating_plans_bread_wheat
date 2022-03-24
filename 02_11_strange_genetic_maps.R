

# Interpolate genetic position of genotyped markers based on a genetic_map specific genetic map
# Input : genetic maps + marker position
# Output : genetic positions of genotyped markers



Sys.time()
cat("\n\nstrange_genetic_maps.R\n\n")
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



titre_genetic_map_input <- variables[1]
titre_nolinkagegroup <- variables[2]
titre_mapx <- variables[3]
titre_genasphy <- variables[4]



#titre_genetic_map_input <-"/home/adanguydesd/Documents/These_Alice/croisements/temp/markers.txt"




cat("\n\n INPUT : markers info \n\n")
map <- fread(titre_genetic_map_input)
head(map)
tail(map)
dim(map)

mapx <- map %>% mutate(dcum=dcum*10) %>%
  mutate(genetic_map="mapx3")


average_cm_per_mb <- map %>%
  group_by(chr) %>%
  summarise(pmax=max(pos)/1e6, dcum_max=max(dcum), average_cm_per_mb=dcum_max/pmax) %>%
  ungroup() %>%
  summarise(average_cm_per_mb=mean(average_cm_per_mb)) %>%
  unlist() %>%
  as.vector()


genasphy <- map %>% mutate(dcum=(pos/1e6)*!!average_cm_per_mb) %>%
  group_by(chr) %>%
  mutate(dcum=dcum-min(dcum))%>%
  mutate(genetic_map="genasphy")


nolinkagegroup <- map %>% mutate(dcum=1e6*dcum) %>%
  mutate(genetic_map="nolinkagegroup")


cat("\n\n map * x \n\n")
head(mapx)
tail(mapx)
dim(mapx)
write.table(mapx, titre_mapx, col.names = T, row.names = F, dec=".", sep="\t", quote=F)

cat("\n\n no genetic position \n\n")
head(genasphy)
tail(genasphy)
dim(genasphy)
write.table(genasphy, titre_genasphy, col.names = T, row.names = F, dec=".", sep="\t", quote=F)

cat("\n\n no linkage group \n\n")
head(nolinkagegroup)
tail(nolinkagegroup)
dim(nolinkagegroup)
write.table(nolinkagegroup, titre_nolinkagegroup, col.names = T, row.names = F, dec=".", sep="\t", quote=F)



sessionInfo()
