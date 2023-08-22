



Sys.time()
cat("\n\nsimulation_donnees_pipeline.R\n\n")
rm(list = ls())
graphics.off()
set.seed(1)

suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(compiler))



titre_genotyping_matrice_parents <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/genotyping.txt"
titre_markers <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/markers.txt"
titre_markers_output <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/FD_markers.txt"
titre_genotyping_matrice_parents_output <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/FD_genotyping.txt"
titre_fonction_calcul1 <- "/home/adanguydesd/Documents/These_Alice/croisements/scripts/calcul_index_variance_crosses.R"
titre_crosses_output <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/FD_crosses.txt"

source(titre_fonction_calcul1)

g <- fread(titre_genotyping_matrice_parents)
m <- fread(titre_markers) %>%
  filter(population=="WE") %>%
  group_by(chr) %>%
  slice(sort(sample(1:n(), size=10, replace=F))) %>%
  dplyr::select(chr, marker, dcum) %>%
  arrange(chr, dcum) %>%
  mutate(value=rnorm(n(), mean=0, sd=1))

g <- g%>% dplyr::select(one_of("ID",m$marker)) %>%
  slice(sort(sample(1:n(), size=10, replace=F))) %>%
  arrange(ID)

lines_to_keep <- calcul1(10)

c <- expand.grid(unlist(g$ID),
            unlist(g$ID)) %>%
  slice(lines_to_keep) %>%
  rename(P2=Var1, P1=Var2) %>%
  arrange(P1, P2) %>%
  dplyr::select(P1, P2)


gebv <- data.frame(P1=g$ID, gebv=tcrossprod(g %>% dplyr::select(-ID) %>% as.matrix(), matrix(m$value, nrow=1)))

c <- c %>% inner_join( gebv, by=c("P1")) %>%
  inner_join(gebv, by=c("P2"="P1")) %>%
  mutate(gebv=(gebv.x+gebv.y)/2) %>%
  dplyr::select(P1, P2, gebv)

write.table(m, titre_markers_output, col.names = T, row.names = F, dec=".", sep="\t", quote=F)
write.table(g, titre_genotyping_matrice_parents_output, col.names = T, row.names = F, dec=".", sep="\t", quote=F)
write.table(c, titre_crosses_output, col.names = T, row.names = F, dec=".", sep="\t", quote=F)
